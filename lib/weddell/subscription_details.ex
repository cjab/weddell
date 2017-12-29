defmodule Weddell.SubscriptionDetails do
  @moduledoc """
  A description of a Pub/Sub subscription.
  """
  alias Google.Pubsub.V1.Subscription
  alias Weddell.Client.Util

  @type t :: %__MODULE__{
    name: String.t,
    project: String.t,
    topic: String.t,
    ack_deadline_seconds: pos_integer,
    push_endpoint: String.t,
    push_attributes: %{optional(String.t) => String.t}}

  defstruct [:name, :topic, :project, :ack_deadline_seconds,
             :push_endpoint, :push_attributes]

  @doc false
  def new(%Subscription{} = sub) do
    project = Util.parse_full_project(sub.name)
    name = Util.parse_full_subscription(sub.name)
    topic = Util.parse_full_topic(sub.topic)

    %__MODULE__{name: name, topic: topic, project: project,
      ack_deadline_seconds: sub.ack_deadline_seconds,
      push_endpoint: sub.push_config.push_endpoint,
      push_attributes: sub.push_config.attributes}
  end
end
