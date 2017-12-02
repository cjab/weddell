defmodule Pubsub.TopicDetailsTest do
  use ExUnit.Case
  alias Pubsub.TopicDetails
  alias Google_Pubsub_V1.Topic
  alias Pubsub.Client.Util

  @project "test-project"
  @topic "test-topic"

  describe "TopicDetails.new/1" do
    test "from a Google_Pubsub_V1.Topic" do
      topic = Topic.new(name: Util.full_topic(@project, @topic))
      assert %TopicDetails{project: @project, name: @topic} ==
        TopicDetails.new(topic)
    end
  end
end
