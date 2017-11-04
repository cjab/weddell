defmodule PubsubTest do
  use ExUnit.Case
  doctest Pubsub

  @topic "projects/blarg/topics/test-topic"
  @subscription "projects/blarg/subscriptions/test-subscription"

  test "it works" do
    {:ok, channel} = GRPC.Stub.connect("localhost:8085")
    IO.inspect(channel)

    #    topic =
    #      Google_Pubsub_V1.Topic.new(name: @topic)
    #      IO.inspect(topic)
    #    channel
    #    |> Google_Pubsub_V1.Publisher.Stub.create_topic(topic)
    #    |> IO.inspect()

    #    subscription =
    #      Google_Pubsub_V1.Subscription.new(name: @subscription, topic: @topic)
    #    channel
    #    |> Google_Pubsub_V1.Subscriber.Stub.create_subscription(subscription)
    #    |> IO.inspect()

    post_request =
      Google_Pubsub_V1.PublishRequest.new(
        topic: @topic, messages: [
          %Google_Pubsub_V1.PubsubMessage{data: "lol", attributes: %{}, message_id: "5"}])
    channel
    |> Google_Pubsub_V1.Publisher.Stub.publish(post_request)
    |> IO.inspect()

    pull_request =
      Google_Pubsub_V1.PullRequest.new(
        subscription: @subscription, return_immediately: true, max_messages: 1)
    channel
    |> Google_Pubsub_V1.Subscriber.Stub.pull(pull_request)
    |> IO.inspect()
  end
end
