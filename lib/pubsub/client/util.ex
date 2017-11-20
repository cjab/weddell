defmodule Pubsub.Client.Util do
  @moduledoc false

  @spec full_subscription(project :: String.t, subscription :: String.t) :: String.t
  def full_subscription(project, name) do
    "projects/#{project}/subscriptions/#{name}"
  end

  @spec full_topic(project :: String.t, topic :: String.t) :: String.t
  def full_topic(project, name) do
    "projects/#{project}/topics/#{name}"
  end
end
