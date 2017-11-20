defmodule Pubsub.SubscriptionDetails do
  @moduledoc """
  A struct storing information about a subscription
  """
  alias Google_Pubsub_V1.Subscription

  @type t :: %__MODULE__{
    name: String.t,
    topic: String.t,
    ack_deadline_seconds: pos_integer,
    push_endpoint: String.t,
    push_attributes: %{optional(String.t) => String.t}}

  defstruct [:name, :topic, :ack_deadline_seconds,
             :push_endpoint, :push_attributes]

  def new(%Subscription{} = sub) do
    %__MODULE__{name: sub.name, topic: sub.topic,
      ack_deadline_seconds: sub.ack_deadline_seconds,
      push_endpoint: sub.push_config.push_endpoint,
      push_attributes: sub.push_config.attributes}
  end
end
