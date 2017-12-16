defmodule Weddell.PublisherStub do
  alias GRPC.Channel
  alias Google_Protobuf.Empty
  alias Google_Pubsub_V1.{Topic,
                          PublishRequest,
                          PublishResponse,
                          ListTopicRequest,
                          ListTopicsResponse,
                          DeleteTopicRequest}
  alias Weddell.Client

  @callback create_topic(Channel.t, Topic.t, Keyword.t) ::
    {:ok, Topic.t} | Client.error
  @callback delete_topic(Channel.t, DeleteTopicRequest.t, Keyword.t) ::
    {:ok, Empty.t} | Client.error
  @callback list_topics(Channel.t, ListTopicRequest.t, Keyword.t) ::
    {:ok, ListTopicsResponse.t} | Client.error
  @callback publish(Channel.t, PublishRequest.t, Keyword.t) ::
    {:ok, PublishResponse.t} | Client.error
end

Mox.defmock(Weddell.PublisherStubMock, for: Weddell.PublisherStub)
