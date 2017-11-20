defmodule Pubsub.Client do
  @moduledoc """
  A persistent process responsible for interacting with Pusub over GRPC.
  """
  use GenServer

  alias GRPC.Stub
  alias Google_Protobuf.Empty
  alias Google_Pubsub_V1.Topic
  alias Google_Pubsub_V1.PushConfig
  alias Google_Pubsub_V1.PullRequest
  alias Google_Pubsub_V1.PullResponse
  alias Google_Pubsub_V1.Subscription
  alias Google_Pubsub_V1.PubsubMessage
  alias Google_Pubsub_V1.PublishRequest
  alias Google_Pubsub_V1.PublishResponse
  alias Google_Pubsub_V1.ListTopicsRequest
  alias Google_Pubsub_V1.ListTopicsResponse
  alias Google_Pubsub_V1.AcknowledgeRequest
  alias Google_Pubsub_V1.DeleteTopicRequest
  alias Google_Pubsub_V1.ListSubscriptionsRequest
  alias Google_Pubsub_V1.ListSubscriptionsResponse
  alias Google_Pubsub_V1.DeleteSubscriptionRequest
  alias Google_Pubsub_V1.ListSubscriptionRequest
  alias Google_Pubsub_V1.Publisher.Stub, as: Publisher
  alias Google_Pubsub_V1.Subscriber.Stub, as: Subscriber

  alias Pubsub.SubscriptionDetails

  @default_list_max 50

  @doc """
  Start the client process and connect to Pubsub using settings in the application config.

  ## Example

  In your application config:

      config :pubsub,
        host: "localhost",
        port: 8085,
        ca_path: "/usr/local/etc/openssl/cert.pem",
        project: "test-project"

  ## Settings

    * `project` - The __required__ Google Cloud project that will be used for all calls made by this client.
    * `host` - The pubsub host to connect to. This defaults to Google's pubsub service but
      is useful for connecting to a local pubsub emulator _(default: "pubsub.googleapis.com")_
    * `port` - The port on which to connect to the host. _(default: 443)_
    * `ca_path` - The path to a pem formatted ca cert chain. _(default: nil)_
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    ca_path = Application.get_env(:pubsub, :ca_path)
    cred = if ca_path, do: GRPC.Credential.client_tls(ca_path), else: nil
    host = Application.get_env(:pubsub, :host, "pubsub.googleapis.com")
    port = Application.get_env(:pubsub, :port, 443)
    project = Application.get_env(:pubsub, :project)
    {:ok, channel} =
      Stub.connect("#{host}:#{port}", cred: cred)
    {:ok, {channel, project}}
  end

  def handle_call({:create_topic, name}, _from, {channel, project} = state) do
    topic = Topic.new(name: full_topic(project, name))
    channel
    |> Publisher.create_topic(topic, metadata())
    |> case do
      {:error, _rpc_error} = error ->
        {:reply, error, state}
      {:ok, %Topic{}} ->
        {:reply, :ok, state}
    end
  end

  def handle_call({:delete_topic, name}, _from, {channel, project} = state) do
    request = DeleteTopicRequest.new(name: full_topic(project, name))
    channel
    |> Publisher.delete_topic(request, metadata())
    |> case do
      {:error, _rpc_error} = error ->
        {:reply, error, state}
      {:ok, %Empty{}} ->
        {:reply, :ok, state}
    end
  end

  def handle_call({:topics, opts}, _from, {channel, project} = state) do
    max_topics = Keyword.get(opts, :max, @default_list_max)
    cursor = Keyword.get(opts, :cursor, "")
    request = ListTopicsRequest.new(project: "projects/#{project}",
                                    page_size: max_topics,
                                    page_token: cursor)
    channel
    |> Publisher.list_topics(request, metadata())
    |> case do
      {:error, _rpc_error} = error ->
        {:reply, error, state}
      {:ok, %ListTopicsResponse{topics: topics, next_page_token: ""}} ->
        {:reply, {:ok, Enum.map(topics, &(&1.name))}, state}
      {:ok, %ListTopicsResponse{topics: topics, next_page_token: next_cursor}} ->
        {:reply, {:ok, Enum.map(topics, &(&1.name)), next_cursor}, state}
    end
  end

  def handle_call({:create_subscription, name, topic, opts}, _from, {channel, project} = state) do
    ack_deadline = Keyword.get(opts, :ack_deadline_seconds, 10)
    push_config = case Keyword.get(opts, :push_endpoint, nil) do
      nil -> nil
      endpoint -> PushConfig.new(push_endpoint: endpoint)
    end
    subscription = Subscription.new(topic: full_topic(project, topic),
                                    name: full_subscription(project, name),
                                    push_config: push_config,
                                    ack_deadline_seconds: ack_deadline)
    channel
    |> Subscriber.create_subscription(subscription, metadata())
    |> case do
      {:error, _rpc_error} = error ->
        {:reply, error, state}
      {:ok, _subscription} ->
        {:reply, :ok, state}
    end
  end

  def handle_call({:delete_subscription, name}, _from, {channel, project} = state) do
    request =
      DeleteSubscriptionRequest.new(
        subscription: full_subscription(project, name))
    channel
    |> Subscriber.delete_subscription(request, metadata())
    |> case do
      {:error, _rpc_error} = error ->
        {:reply, error, state}
      {:ok, %Empty{}} ->
        {:reply, :ok, state}
    end
  end

  def handle_call({:subscriptions, opts}, _from, {channel, project} = state) do
    max_topics = Keyword.get(opts, :max, @default_list_max)
    cursor = Keyword.get(opts, :cursor, "")
    request = ListSubscriptionsRequest.new(project: "projects/#{project}",
                                    page_size: max_topics,
                                    page_token: cursor)
    channel
    |> Subscriber.list_subscriptions(request, metadata())
    |> case do
      {:error, _rpc_error} = error ->
        {:reply, error, state}
      {:ok, %ListSubscriptionsResponse{next_page_token: ""} = response} ->
        details = Enum.map(response.subscriptions, &(SubscriptionDetails.new(&1)))
        {:reply, {:ok, details}, state}
      {:ok, %ListSubscriptionsResponse{next_page_token: next_cursor} = response} ->
        details = Enum.map(response.subscriptions, &(SubscriptionDetails.new(&1)))
        {:reply, {:ok, details, next_cursor}, state}
    end
  end

  def handle_call({:publish, data, topic}, from, state) when not is_list(data),
    do: handle_call({:publish, [data], topic}, from, state)
  def handle_call({:publish, data, topic}, _from, {channel, project} = state) do
    messages = for d <- data, do: PubsubMessage.new(data: d)
    request = PublishRequest.new(topic: full_topic(project, topic),
                                 messages: messages,
                                 attributes: %{})
    channel
    |> Publisher.publish(request, metadata())
    |> case do
      {:error, _rpc_error} = error ->
        {:reply, error, state}
      {:ok, %PublishResponse{message_ids: ids}} ->
        {:reply, {:ok, ids}, state}
    end
  end

  def handle_call({:pull, subscription, opts}, _from, {channel, project} = state) do
    request = PullRequest.new(subscription: full_subscription(project, subscription),
                              return_immediately: Keyword.get(opts, :return_immediately, true),
                              max_messages: Keyword.get(opts, :max_messages, 1))
    channel
    |> Subscriber.pull(request, metadata())
    |> case do
      {:error, _rpc_error} = error ->
        {:reply, error, state}
      {:ok, %PullResponse{received_messages: messages}} ->
        {:reply, {:ok, messages}, state}
    end
  end

  def handle_call({:acknowledge, ack_id, subscription}, from, state) when not is_list(ack_id),
    do: handle_call({:acknowledge, [ack_id], subscription}, from, state)
  def handle_call({:acknowledge, ack_ids, subscription}, _from, {channel, project} = state) do
    request = AcknowledgeRequest.new(subscription: full_subscription(project, subscription),
                                     ack_ids: ack_ids)
    channel
    |> Subscriber.acknowledge(request, metadata())
    |> case do
      {:error, _rpc_error} = error ->
        {:reply, error, state}
      {:ok, %Empty{}} ->
        {:reply, :ok, state}
    end
  end

  def handle_info(_, state), do: {:noreply, state}

  defp full_topic(project, name), do: "projects/#{project}/topics/#{name}"

  defp full_subscription(project, name), do: "projects/#{project}/subscriptions/#{name}"

  defp metadata, do: [metadata: auth_header(), content_type: "application/grpc"]

  defp auth_header do
    {:ok, %{token: token, type: token_type}} =
      Goth.Token.for_scope("https://www.googleapis.com/auth/pubsub")
    %{"authorization" => "#{token_type} #{token}"}
  end

  defp subscription_details(subscriptions) do
    Enum.map(subscriptions, &(SubscriptionDetails.new(&1)))
  end
end
