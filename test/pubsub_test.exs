defmodule PubsubTest do
  use ExUnit.Case
  doctest Pubsub

  test "it works" do
    Pubsub.delete_topic("test-topic-7")
    |> IO.inspect()
    Pubsub.create_topic("test-topic-7")
    |> IO.inspect()
    #Pubsub.create_subscription("test-subscription-4", "test-topic-4")
    #Pubsub.publish("test-message-data", "test-topic-4")
    #Pubsub.pull("test-subscription-4")
  end
end
