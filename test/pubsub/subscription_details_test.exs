defmodule Pubsub.SubscriptionDetailsTest do
  use ExUnit.Case
  alias Pubsub.SubscriptionDetails
  alias Google_Pubsub_V1.Subscription
  alias Pubsub.Client.Util

  @project "test-project"
  @topic "test-topic"
  @subscription "test-subscription"
  @deadline 10
  @push_config %{push_endpoint: "https://example.org",
                 attributes: %{"attribute-1" => "value-1", "attribute-2" => "value-2"}}

  describe "SubscriptionDetails.new/1" do
    test "from a Google_Pubsub_V1.Subscription" do
      topic = Subscription.new(name: Util.full_subscription(@project, @subscription),
                               topic: Util.full_topic(@project, @topic),
                               ack_deadline_seconds: @deadline,
                               push_config: @push_config)
      expected = %SubscriptionDetails{project: @project, name: @subscription, topic: @topic,
                                      ack_deadline_seconds: @deadline,
                                      push_endpoint: @push_config.push_endpoint,
                                      push_attributes: @push_config.attributes}
      assert expected  ==
        SubscriptionDetails.new(topic)
    end
  end
end
