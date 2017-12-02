defmodule Pubsub.PublisherStub do
  alias GRPC.Channel
  alias Pubsub.Client
  alias Google_Protobuf.Empty
  alias Google_Pubsub_V1.Topic
  alias Google_Pubsub_V1.PublishRequest
  alias Google_Pubsub_V1.PublishResponse
  alias Google_Pubsub_V1.ListTopicsRequest
  alias Google_Pubsub_V1.ListTopicsResponse
  alias Google_Pubsub_V1.DeleteTopicRequest

  @callback create_topic(Channel.t, Topic.t, Keyword.t) ::
    {:ok, Topic.t} | Client.error
  @callback delete_topic(Channel.t, DeleteTopicRequst.t, Keyword.t) ::
    {:ok, Empty.t} | Client.error
  @callback list_topics(Channel.t, ListTopicRequst.t, Keyword.t) ::
    {:ok, ListTopicsResponse.t} | Client.error
  @callback publish(Channel.t, PublishRequest.t, Keyword.t) ::
    {:ok, PublishResponse.t} | Client.error
end

Mox.defmock(Pubsub.PublisherStubMock, for: Pubsub.PublisherStub)
