defmodule Weddell.TopicDetailsTest do
  use Weddell.UnitCase

  alias Google.Pubsub.V1.Topic
  alias Weddell.{TopicDetails,
                 Client.Util}

  @project "test-project"
  @topic "test-topic"

  describe "TopicDetails.new/1" do
    test "from a Google.Pubsub.V1.Topic" do
      topic = Topic.new(name: Util.full_topic(@project, @topic))
      assert %TopicDetails{project: @project, name: @topic} ==
        TopicDetails.new(topic)
    end
  end
end
