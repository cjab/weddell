defmodule Weddell.Client.Util do
  @moduledoc false

  @subscription_regex ~r/projects\/.+\/subscriptions\/.+/
  @topics_regex ~r/projects\/.+\/topics\/.+/

  @spec full_subscription(project :: String.t, subscription :: String.t) :: String.t
  def full_subscription(project, "projects/" <> _ = name) do
    case Regex.match?(@subscription_regex, name) do
      true  -> name
      false -> make_full_subscription(project, name)
    end
  end
  def full_subscription(project, name) do
    make_full_subscription(project, name)
  end

  defp make_full_subscription(project, name) do
    "#{full_project(project)}/subscriptions/#{name}"
  end

  @spec full_topic(project :: String.t, topic :: String.t) :: String.t
  def full_topic(project, "projects/" <> _ = name) do
    case Regex.match?(@topics_regex, name) do
      true  -> name
      false -> make_full_topic(project, name)
    end
  end
  def full_topic(project, name) do
    make_full_topic(project, name)
  end

  defp make_full_topic(project, name) do
    "#{full_project(project)}/topics/#{name}"
  end

  @spec full_project(project :: String.t) :: String.t
  def full_project(project) do
    "projects/#{project}"
  end

  @spec parse_full_topic(full_topic :: String.t) :: String.t
  def parse_full_topic(full_topic) do
    %{"topic" => topic} =
      ~r|projects/(?<project>[^/]*)/topics/(?<topic>.*)|
      |> Regex.named_captures(full_topic)
    topic
  end

  @spec parse_full_subscription(full_subscription :: String.t) :: String.t
  def parse_full_subscription(full_subscription) do
    %{"subscription" => subscription} =
      ~r|projects/(?<project>[^/]*)/subscriptions/(?<subscription>.*)|
      |> Regex.named_captures(full_subscription)
    subscription
  end

  @spec parse_full_project(full_project :: String.t) :: String.t
  def parse_full_project(full_project) do
    %{"project" => project} =
      ~r|projects/(?<project>[^/]*)|
      |> Regex.named_captures(full_project)
    project
  end
end
