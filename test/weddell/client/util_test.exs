defmodule Weddell.Client.UtilTest do
  use Weddell.UnitCase

  alias Weddell.Client.Util

  @project "test-project"
  @topic "test-topic"
  @subscription "test-subscription"

  describe "Util.full_subscription\2" do
    test "builds a full subscription string" do
      assert Util.full_subscription(@project, @subscription) ==
        "projects/#{@project}/subscriptions/#{@subscription}"
    end
    test "returns original string if it's a fully qualified subscription" do
      full_subscription = "projects/myproject/subscriptions/mysubscription"
      assert Util.full_subscription(@project, full_subscription) == full_subscription
    end
    test "builds a full subscription if not fully qualified" do
      subscriptions = [
        "projects/myproject/subscription/mysubscription", # without s in subscriptions
        "projects/myproject/subscriptionsmysubscription", # missing slash
        "projects//subscriptions/mysubscription", # missing project
        "projects/myproject/subscriptions/", # missing subscription name
        "projects/myproject/something" # missing subscriptions bit
      ]
      Enum.each(subscriptions, fn(sub) ->
        assert Util.full_subscription(@project, sub) == "projects/#{@project}/subscriptions/#{sub}"
      end)
    end
  end

  describe "Util.full_topic\2" do
    test "builds a full topic string" do
      assert Util.full_topic(@project, @topic) ==
        "projects/#{@project}/topics/#{@topic}"
    end
    test "returns original string if it's a fully qualified topic" do
      full_topic = "projects/myproject/topics/mytopic"
      assert Util.full_topic(@project, full_topic) == full_topic
    end
    test "builds a full topic if not fully qualified" do
      topics = [
        "projects/myproject/topic/mytopic", # without s in topics
        "projects/myproject/topicsmytopic", # missing slash
        "projects//topics/mytopic", # missing project
        "projects/myproject/topics/", # missing topic name
        "projects/myproject/something" # missing topics bit
      ]
      Enum.each(topics, fn(topic) ->
        assert Util.full_topic(@project, topic) == "projects/#{@project}/topics/#{topic}"
      end)
    end
  end

  describe "Util.full_project\2" do
    test "builds a full project string" do
      assert Util.full_project(@project) ==
        "projects/#{@project}"
    end
  end
end
