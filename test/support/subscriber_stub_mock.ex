defmodule Pubsub.SubscriberStub do
  alias Google_Pubsub_V1.Subscription
  alias Pubsub.Client
  alias GRPC.Channel

  @callback create_subscription(Channel.t, Subscription.t, Keyword.t) :: :ok | Client.error
end

Mox.defmock(Pubsub.SubscriberStubMock, for: Pubsub.SubscriberStub)
