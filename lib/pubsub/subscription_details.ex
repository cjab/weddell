defmodule Pubsub.SubscriptionDetails do
  alias Google_Pubsub_V1.Subscription

  defstruct [:name, :topic, :ack_deadline_seconds,
             :push_endpoint, :push_attributes]

  def new(%Subscription{} = sub) do
    %__MODULE__{name: sub.name, topic: sub.topic,
      ack_deadline_seconds: sub.ack_deadline_seconds,
      push_endpoint: sub.push_config.push_endpoint,
      push_attributes: sub.push_config.attributes}
  end
end
