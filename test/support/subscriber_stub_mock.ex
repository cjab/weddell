defmodule Weddell.SubscriberStub do
  alias GRPC.Channel
  alias Google.Protobuf.Empty
  alias Google.Pubsub.V1.{Subscription,
                          DeleteSubscriptionRequest,
                          ListSubscriptionsRequest,
                          ListSubscriptionsResponse,
                          PullRequest,
                          PullResponse}
  alias Weddell.Client

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

Mox.defmock(Weddell.SubscriberStubMock, for: Weddell.SubscriberStub)
