defmodule Weddell.PublisherStub do
  alias GRPC.Channel
  alias Google.Protobuf.Empty
  alias Google.Pubsub.V1.{Topic,
                          PublishRequest,
                          PublishResponse,
                          ListTopicRequest,
                          ListTopicsResponse,
                          ListTopicSubscriptionsRequest,
                          ListTopicSubscriptionsResponse,
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
  @callback list_topic_subscriptions(Channel.t, ListTopicSubscriptionsRequest.t, Keyword.t) ::
    {:ok, ListTopicSubscriptionsResponse.t} | Client.error
end

Mox.defmock(Weddell.PublisherStubMock, for: Weddell.PublisherStub)
