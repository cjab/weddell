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
  end

  describe "Util.full_topic\2" do
    test "builds a full topic string" do
      assert Util.full_topic(@project, @topic) ==
        "projects/#{@project}/topics/#{@topic}"
    end
  end

  describe "Util.full_project\2" do
    test "builds a full project string" do
      assert Util.full_project(@project) ==
        "projects/#{@project}"
    end
  end
end
