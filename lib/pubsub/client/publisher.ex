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
  alias Pubsub.Client
  alias Pubsub.Client.Util
  alias Pubsub.TopicDetails

  @default_list_max 50

  defp stub_module do
    Application.get_env(:pubsub, :publisher_stub, Google_Pubsub_V1.Publisher.Stub)
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
    |> stub_module().publish(request, Client.request_opts(client))
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %PublishResponse{message_ids: ids}} -> {:ok, ids}
    end
  end
end
