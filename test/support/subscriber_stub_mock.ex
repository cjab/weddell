defmodule Pubsub.SubscriberStub do
  alias Google_Pubsub_V1.Subscription
  alias Google_Pubsub_V1.DeleteSubscriptionRequest
  alias Pubsub.Client
  alias GRPC.Channel

  @callback create_subscription(Channel.t, Subscription.t, Keyword.t) ::
    :ok | Client.error
  @callback delete_subscription(Channel.t, DeleteSubscriptionRequest.t, Keyword.t) ::
    :ok | Client.error
  @callback list_subscriptions(Channel.t, ListSubscriptionsRequest.t, Keyword.t) ::
    {:ok, [SubscriptionDetails.t]} |
    {:ok, [SubscriptionDetails.t], Client.cursor} |
    Client.error
end

Mox.defmock(Pubsub.SubscriberStubMock, for: Pubsub.SubscriberStub)
