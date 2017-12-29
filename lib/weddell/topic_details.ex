defmodule Weddell.TopicDetails do
  @moduledoc """
  A description of a Pub/Sub topic.
  """
  alias Google.Pubsub.V1.Topic

  @type t :: %__MODULE__{name: String.t, project: String.t}
  defstruct [:name, :project]

  @doc false
  def new(%Topic{name: topic}) do
    %{"project" => project, "name" => name} =
      ~r|projects/(?<project>[^/]*)/topics/(?<name>.*)|
      |> Regex.named_captures(topic)
    %__MODULE__{name: name, project: project}
  end
end
