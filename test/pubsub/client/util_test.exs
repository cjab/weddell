defmodule Pubsub.Client.UtilTest do
  use ExUnit.Case
  alias Pubsub.Client.Util

  @project "test-project"
  @topic "test-topic"
  @subscription "test-subscription"

  describe "Util.full_subscription\2" do
    test "builds a full subscription string" do
      assert Util.full_subscription(@project, @subscription) ==
        "projects/#{@project}/subscriptions/#{@subscription}"
    end
  end

  describe "Util.full_topic\2" do
    test "builds a full topic string" do
      assert Util.full_topic(@project, @topic) ==
        "projects/#{@project}/topics/#{@topic}"
    end
  end
end
