defmodule Pubsub.MessageTest do
  use ExUnit.Case
  alias Pubsub.Message
  alias Google_Protobuf.Timestamp
  alias Google_Pubsub_V1.PubsubMessage
  alias Google_Pubsub_V1.ReceivedMessage

  @data "data"
  @ack_id "ack-id"
  @id "id"

  describe "Message.new/1" do
    test "from a Google_Pubsub_V1.ReceivedMessage" do
      now =
        DateTime.utc_now() |> DateTime.to_unix()
      attributes = %{"key1" => "val1", "key2" => "val2"}
      pubsub_message =
        PubsubMessage.new(data: @data,
                          attributes: attributes,
                          message_id: @id,
                          publish_time: Timestamp.new(seconds: now))
      received_message =
        ReceivedMessage.new(%{ack_id: @ack_id, message: pubsub_message})
      assert %Message{id: @id,
                      ack_id: @ack_id,
                      published_at: DateTime.from_unix!(now),
                      attributes: attributes,
                      data: @data} == Message.new(received_message)
    end
  end
end
