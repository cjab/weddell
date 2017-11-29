defmodule Pubsub.SubscriberStub do
  alias Google_Pubsub_V1.Subscription
  alias Google_Pubsub_V1.DeleteSubscriptionRequest
  alias Google_Pubsub_V1.ListSubscriptionsRequest
  alias Google_Pubsub_V1.ListSubscriptionsResponse
  alias Google_Pubsub_V1.PullRequest
  alias Google_Pubsub_V1.PullResponse
  alias Google_Protobuf.Empty
  alias Pubsub.Client
  alias GRPC.Channel

  @callback create_subscription(Channel.t, Subscription.t, Keyword.t) ::
    {:ok, Subscription.t} | Client.error
  @callback delete_subscription(Channel.t, DeleteSubscriptionRequest.t, Keyword.t) ::
    {:ok, Empty.t} | Client.error
  @callback list_subscriptions(Channel.t, ListSubscriptionsRequest.t, Keyword.t) ::
    {:ok, ListSubscriptionsResponse.t} | Client.error
  @callback pull(Channel.t, PullRequest.t, Keyword.t) ::
    {:ok, PullResponse.t} | Client.error
  @callback acknowledge(Channel.t, AcknowledgeRequest.t, Keyword.t) ::
    {:ok, Empty.t} | Client.error
end

Mox.defmock(Pubsub.SubscriberStubMock, for: Pubsub.SubscriberStub)
