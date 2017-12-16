defmodule Weddell.Client.Publisher do
  @moduledoc false
  alias Google_Protobuf.Empty
  alias Google_Pubsub_V1.{Topic,
                          Publisher.Stub,
                          PubsubMessage,
                          PublishRequest,
                          PublishResponse,
                          ListTopicsRequest,
                          ListTopicsResponse,
                          DeleteTopicRequest}
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
    |> stub_module().create_topic(topic, Client.request_opts(client))
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %Topic{}} -> :ok
    end
  end

  @spec delete_topic(Client.t, name :: String.t) :: :ok | Client.error
  def delete_topic(client, name) do
    request = DeleteTopicRequest.new(topic: Util.full_topic(client.project, name))
    client.channel
    |> stub_module().delete_topic(request, Client.request_opts(client))
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %Empty{}} -> :ok
    end
  end

  @spec topics(Client.t, opts :: Client.list_opt) ::
    {:ok, [String.t]} | Client.error
  def topics(client, opts \\ []) do
    max_topics = Keyword.get(opts, :max, @default_list_max)
    cursor = Keyword.get(opts, :cursor, "")
    request = ListTopicsRequest.new(project: "projects/#{client.project}",
                                    page_size: max_topics,
                                    page_token: cursor)
    client.channel
    |> stub_module().list_topics(request, Client.request_opts(client))
    |> case do
      {:error, _rpc_error} = error ->
        error
      {:ok, %ListTopicsResponse{topics: topics, next_page_token: nil}} ->
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
    |> stub_module().publish(request, Client.request_opts(client))
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %PublishResponse{}} -> :ok
    end
  end
end
