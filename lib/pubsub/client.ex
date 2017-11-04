defmodule Pubsub.Client do
  @moduledoc """
  Documentation for Pubsub.
  """
  use GenServer

  alias GRPC.Stub
  alias Google_Pubsub_V1.Topic
  alias Google_Pubsub_V1.PushConfig
  alias Google_Pubsub_V1.PullRequest
  alias Google_Pubsub_V1.Subscription
  alias Google_Pubsub_V1.PubsubMessage
  alias Google_Pubsub_V1.PublishRequest
  alias Google_Pubsub_V1.AcknowledgeRequest
  alias Google_Pubsub_V1.Publisher.Stub, as: Publisher
  alias Google_Pubsub_V1.Subscriber.Stub, as: Subscriber

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    host = Application.get_env(:pubsub, :host)
    port = Application.get_env(:pubsub, :port)
    project = Application.get_env(:pubsub, :project)
    {:ok, channel} = Stub.connect("#{host}:#{port}")
    {:ok, {channel, project}}
  end

  def handle_call({:create_topic, name}, _from, {channel, project} = state) do
    topic = Topic.new(name: full_topic(project, name))
    channel
    |> Publisher.create_topic(topic)
    {:reply, :ok, state}
  end

  def handle_call({:create_subscription, name, topic, opts}, _from, {channel, project} = state) do
    ack_deadline = Keyword.get(opts, :ack_deadline_seconds, nil)
    push_config = case Keyword.get(opts, :push_endpoint, nil) do
      nil -> nil
      endpoint -> PushConfig.new(push_endpoint: endpoint)
    end
    subscription = Subscription.new(topic: full_topic(project, topic),
                                    name: full_subscription(project, name),
                                    push_config: push_config,
                                    ack_deadline_seconds: ack_deadline)
    channel
    |> Subscriber.create_subscription(subscription)
    {:reply, :ok, state}
  end

  def handle_call({:publish, data, topic}, from, state) when not is_list(data),
    do: handle_call({:publish, [data], topic}, from, state)
  def handle_call({:publish, data, topic}, _from, {channel, project} = state) do
    messages = for d <- data, do: PubsubMessage.new(data: d)
    request = PublishRequest.new(topic: full_topic(project, topic),
                                 messages: messages,
                                 attributes: %{})
    channel
    |> Publisher.publish(request)
    {:reply, :ok, state}
  end

  def handle_call({:pull, subscription, opts}, _from, {channel, project} = state) do
    request = PullRequest.new(subscription: full_subscription(project, subscription),
                              return_immediately: Keyword.get(opts, :return_immediately, true),
                              max_messages: Keyword.get(opts, :max_messages, 1))
    result =
      channel
      |> Subscriber.pull(request)
    {:reply, result, state}
  end

  def handle_call({:acknowledge, ack_id, subscription}, from, state) when not is_list(ack_id),
    do: handle_call({:acknowledge, [ack_id], subscription}, from, state)
  def handle_call({:acknowledge, ack_ids, subscription}, _from, {channel, project} = state) do
    request = AcknowledgeRequest.new(subscription: full_subscription(project, subscription),
                                     ack_ids: ack_ids)
    channel
    |> Subscriber.acknowledge(request)
    {:reply, :ok, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  defp full_topic(project, name), do: "projects/#{project}/topics/#{name}"

  defp full_subscription(project, name), do: "projects/#{project}/subscriptions/#{name}"
end
