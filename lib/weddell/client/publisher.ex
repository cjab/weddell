defmodule Weddell.Client.Publisher do
  @moduledoc false
  alias Google.Protobuf.Empty
  alias Google.Pubsub.V1.{Topic,
                          Publisher.Stub,
                          PubsubMessage,
                          PublishRequest,
                          PublishResponse,
                          ListTopicsRequest,
                          ListTopicsResponse,
                          DeleteTopicRequest,
                          ListTopicSubscriptionsRequest,
                          ListTopicSubscriptionsResponse}
  alias Weddell.{Client,
                 Client.Util,
                 TopicDetails}

  @default_list_max 50

  @typedoc "A new Pub/Sub message -- can contain data, attributes, or both"
  @type new_message :: data :: binary |
                       attributes :: map |
                       {data :: binary, attributes :: map}

  defp stub_module do
    Application.get_env(:weddell, :publisher_stub, Stub)
  end

  @spec create_topic(Client.t, name :: String.t) :: :ok | Client.error
  def create_topic(client, name) do
    topic = Topic.new(name: Util.full_topic(client.project, name))
    client.channel
    |> stub_module().create_topic(topic, Client.request_opts())
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %Topic{}} -> :ok
    end
  end

  @spec delete_topic(Client.t, name :: String.t) :: :ok | Client.error
  def delete_topic(client, name) do
    request = DeleteTopicRequest.new(topic: Util.full_topic(client.project, name))
    client.channel
    |> stub_module().delete_topic(request, Client.request_opts())
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %Empty{}} -> :ok
    end
  end

  @spec topics(Client.t, opts :: Client.list_options) ::
    {:ok, [TopicDetails.t]} |
    {:ok, [TopicDetails.t], Client.cursor} |
    Client.error
  def topics(client, opts \\ []) do
    max_topics = Keyword.get(opts, :max, @default_list_max)
    cursor = Keyword.get(opts, :cursor, "")
    request = ListTopicsRequest.new(project: "projects/#{client.project}",
                                    page_size: max_topics,
                                    page_token: cursor)
    client.channel
    |> stub_module().list_topics(request, Client.request_opts())
    |> case do
      {:error, _rpc_error} = error ->
        error
      {:ok, %ListTopicsResponse{topics: topics, next_page_token: ""}} ->
        {:ok, Enum.map(topics, &TopicDetails.new/1)}
      {:ok, %ListTopicsResponse{topics: topics, next_page_token: next_cursor}} ->
        {:ok, Enum.map(topics, &TopicDetails.new/1), next_cursor}
    end
  end

  @spec publish(Client.t, new_message | [new_message], topic :: String.t) :: :ok | Client.error
  def publish(client, message, topic) when not is_list(message),
    do: publish(client, [message], topic)
  def publish(client, messages, topic) do
    messages =
      messages
      |> Enum.map(fn
        data when is_binary(data) ->
          PubsubMessage.new(data: data)
        attributes when is_map(attributes) ->
          PubsubMessage.new(attributes: attributes)
        {data, attributes} when is_binary(data) and is_map(attributes) ->
          PubsubMessage.new(data: data, attributes: attributes)
        _message ->
          PubsubMessage.new()
      end)
    request = PublishRequest.new(topic: Util.full_topic(client.project, topic),
                                 messages: messages)
    client.channel
    |> stub_module().publish(request, Client.request_opts())
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %PublishResponse{}} -> :ok
    end
  end

  @spec topic_subscriptions(Client.t, topic :: String.t, Client.list_options) ::
    {:ok, [String.t]} |
    {:ok, [String.t], Client.cursor} |
    Client.error
  def topic_subscriptions(client, topic, opts \\ []) do
    max_topics = Keyword.get(opts, :max, @default_list_max)
    cursor = Keyword.get(opts, :cursor, "")
    request = ListTopicSubscriptionsRequest.new(topic: Util.full_topic(client.project, topic),
                                                page_size: max_topics,
                                                page_token: cursor)
    client.channel
    |> stub_module().list_topic_subscriptions(request, Client.request_opts())
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %ListTopicSubscriptionsResponse{next_page_token: nil} = response} ->
        {:ok, Enum.map(response.subscriptions, &Util.parse_full_subscription/1)}
      {:ok, %ListTopicSubscriptionsResponse{next_page_token: next_cursor} = response} ->
        {:ok, Enum.map(response.subscriptions, &Util.parse_full_subscription/1), next_cursor}
    end
  end
end
