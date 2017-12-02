defmodule Pubsub.SubscriptionDetails do
  @moduledoc """
  A struct storing information about a subscription
  """
  alias Google_Pubsub_V1.Subscription

  @type t :: %__MODULE__{
    name: String.t,
    project: String.t,
    topic: String.t,
    ack_deadline_seconds: pos_integer,
    push_endpoint: String.t,
    push_attributes: %{optional(String.t) => String.t}}

  defstruct [:name, :topic, :project, :ack_deadline_seconds,
             :push_endpoint, :push_attributes]

  def new(%Subscription{} = sub) do
    %{"project" => project, "name" => name} =
      ~r|projects/(?<project>[^/]*)/subscriptions/(?<name>.*)|
      |> Regex.named_captures(sub.name)
    %{"topic" => topic} =
      ~r|projects/[^/]*/topics/(?<topic>.*)|
      |> Regex.named_captures(sub.topic)

    %__MODULE__{name: name, topic: topic, project: project,
      ack_deadline_seconds: sub.ack_deadline_seconds,
      push_endpoint: sub.push_config.push_endpoint,
      push_attributes: sub.push_config.attributes}
  end
end
