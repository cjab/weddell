defmodule Pubsub.Client.Publisher do
  @moduledoc false
  alias Google_Protobuf.Empty
  alias Google_Pubsub_V1.Topic
  alias Google_Pubsub_V1.PubsubMessage
  alias Google_Pubsub_V1.PublishRequest
  alias Google_Pubsub_V1.PublishResponse
  alias Google_Pubsub_V1.ListTopicsRequest
  alias Google_Pubsub_V1.ListTopicsResponse
  alias Google_Pubsub_V1.DeleteTopicRequest
  alias Google_Pubsub_V1.Publisher.Stub
  alias Pubsub.Client
  alias Pubsub.Client.Util

  @default_list_max 50

  @spec create_topic(Client.t, name :: String.t) :: :ok | Client.error
  def create_topic(client, name) do
    topic = Topic.new(name: Util.full_topic(client.project, name))
    client.channel
    |> Stub.create_topic(topic, client.request_opts)
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %Topic{}} -> :ok
    end
  end

  @spec delete_topic(Client.t, name :: String.t) :: :ok | Client.error
  def delete_topic(client, name) do
    request = DeleteTopicRequest.new(name: Util.full_topic(client.project, name))
    client.channel
    |> Stub.delete_topic(request, client.request_opts)
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %Empty{}} -> :ok
    end
  end

  @spec topics(Client.t, opts :: Client.list_opt) ::
    {:ok, [String.t]} | Client.error
  def topics(client, opts) do
    max_topics = Keyword.get(opts, :max, @default_list_max)
    cursor = Keyword.get(opts, :cursor, "")
    request = ListTopicsRequest.new(project: "projects/#{client.project}",
                                    page_size: max_topics,
                                    page_token: cursor)
    client.channel
    |> Stub.list_topics(request, client.request_opts)
    |> case do
      {:error, _rpc_error} = error ->
        error
      {:ok, %ListTopicsResponse{topics: topics, next_page_token: ""}} ->
        {:ok, Enum.map(topics, &(&1.name))}
      {:ok, %ListTopicsResponse{topics: topics, next_page_token: next_cursor}} ->
        {:ok, Enum.map(topics, &(&1.name)), next_cursor}
    end
  end

  @spec publish(Client.t, data :: binary, topic :: String.t) ::
    {:ok, [message_id :: String.t]} | Client.error
  def publish(client, data, topic) when not is_list(data),
    do: publish(client, [data], topic)
  def publish(client, data, topic) do
    messages = for d <- data, do: PubsubMessage.new(data: d)
    request = PublishRequest.new(topic: Util.full_topic(client.project, topic),
                                 messages: messages,
                                 attributes: %{})
    client.channel
    |> Stub.publish(request, client.request_opts)
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %PublishResponse{message_ids: ids}} -> {:ok, ids}
    end
  end
end
