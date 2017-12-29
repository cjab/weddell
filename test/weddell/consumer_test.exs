defmodule Weddell.ConsumerTest do
  use Weddell.IntegrationCase

  require WaitForIt

  defmodule AckConsumer do
    use Weddell.Consumer

    def handle_messages(messages) do
      {:ok, ack: messages}
    end
  end

  defmodule DelayConsumer do
    use Weddell.Consumer

    def handle_messages(messages) do
      {:ok, delay: Enum.map(messages, &({&1, 1}))}
    end
  end

  setup do
    topic = "test-topic-#{UUID.uuid4()}"
    :ok = Weddell.create_topic(topic)
    subscription = "test-subscription-#{UUID.uuid4()}"
    :ok = Weddell.create_subscription(subscription, topic)
    message = {"test-data", %{"foo" => "bar"}}
    :ok = Weddell.publish(message, topic)
    {:ok, topic: topic, subscription: subscription, message: message}
  end

  test "consumer acks messages",
  %{subscription: subscription} do
    {:ok, _} = AckConsumer.start_link(subscription)
    WaitForIt.wait {:ok, []} == Weddell.pull(subscription) do
      assert true
    else
      assert false, "Message was not processed"
    end
  end

  test "consumer delays messages",
  %{subscription: subscription} do
    {:ok, _} = DelayConsumer.start_link(subscription)
    WaitForIt.wait {:ok, []} == Weddell.pull(subscription) do
      assert true
    else
      assert false, "Message was not processed"
    end
  end
end
