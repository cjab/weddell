defmodule Weddell.Client.Util do
  @moduledoc false

  @spec full_subscription(project :: String.t, subscription :: String.t) :: String.t
  def full_subscription(project, name) do
    "#{full_project(project)}/subscriptions/#{name}"
  end

  @spec full_topic(project :: String.t, topic :: String.t) :: String.t
  def full_topic(project, name) do
    "#{full_project(project)}/topics/#{name}"
  end

  @spec full_project(project :: String.t) :: String.t
  def full_project(project) do
    "projects/#{project}"
  end
end
