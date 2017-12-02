defmodule Pubsub.MessageTest do
  use ExUnit.Case
  alias Pubsub.Message
  alias Google_Pubsub_V1.PubsubMessage

  @data "data"

  describe "Message.new/1" do
    test "from a Google_Pubsub_V1.PubsubMessage" do
      pubsub_message = PubsubMessage.new(data: @data)
      assert %Message{data: @data} ==
        Message.new(pubsub_message)
    end
  end
end
