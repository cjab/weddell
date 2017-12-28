defmodule WeddellTest do
  use Weddell.IntegrationCase

  alias GRPC.RPCError
  alias Weddell.{Message,
                 TopicDetails,
                 SubscriptionDetails}

  describe "Weddell.create_topic/1" do
    test "successfully create a topic" do
      topic = "test-topic-#{UUID.uuid4()}"
      assert :ok == Weddell.create_topic(topic)
    end

    test "fail to create duplicate topic" do
      topic = "test-topic-#{UUID.uuid4()}"
      error = %RPCError{message: "Topic already exists", status: "6"}
      assert :ok == Weddell.create_topic(topic)
      assert {:error, error} == Weddell.create_topic(topic)
    end
  end

  describe "Weddell.delete_topic/1" do
    setup do
      topic = "test-topic-#{UUID.uuid4()}"
      :ok = Weddell.create_topic(topic)
      {:ok, topic: topic}
    end

    test "successfully delete a topic", %{topic: topic} do
      assert :ok == Weddell.delete_topic(topic)
    end

    test "fail to delete a topic" do
      error = %RPCError{message: "Topic not found", status: "5"}
      assert {:error, error} == Weddell.delete_topic("test-topic-not-found")
    end
  end

  describe "Weddell.topics/1" do
    setup do
      topic = "test-topic-#{UUID.uuid4()}"
      :ok = Weddell.create_topic(topic)
      {:ok, topic: topic}
    end

    test "successfully list topics" do
      assert {:ok, [%TopicDetails{}], _} = Weddell.topics(max: 1)
    end
  end

  describe "Weddell.create_subscription/3" do
    setup do
      topic = "test-topic-#{UUID.uuid4()}"
      :ok = Weddell.create_topic(topic)
      {:ok, topic: topic}
    end

    test "successfully create a subscription", %{topic: topic} do
      subscription = "test-subscription-#{UUID.uuid4()}"
      assert :ok == Weddell.create_subscription(subscription, topic)
    end

    test "fail to create duplicate subscription", %{topic: topic} do
      subscription = "test-subscription-#{UUID.uuid4()}"
      error = %RPCError{message: "Subscription already exists", status: "6"}
      assert :ok == Weddell.create_subscription(subscription, topic)
      assert {:error, error} == Weddell.create_subscription(subscription, topic)
    end
  end

  describe "Weddell.delete_subscription/1" do
    setup do
      topic = "test-topic-#{UUID.uuid4()}"
      :ok = Weddell.create_topic(topic)
      subscription = "test-subscription-#{UUID.uuid4()}"
      :ok = Weddell.create_subscription(subscription, topic)
      {:ok, topic: topic, subscription: subscription}
    end

    test "successfully delete a subscription", %{subscription: subscription} do
      assert :ok == Weddell.delete_subscription(subscription)
    end

    test "fail to delete a subscription" do
      error = %RPCError{message: "Subscription does not exist", status: "5"}
      assert {:error, error} == Weddell.delete_subscription("test-subscription-not-found")
    end
  end

  describe "Weddell.subscriptions/1" do
    setup do
      topic = "test-topic-#{UUID.uuid4()}"
      :ok = Weddell.create_topic(topic)
      subscription = "test-subscription-#{UUID.uuid4()}"
      :ok = Weddell.create_subscription(subscription, topic)
      {:ok, topic: topic, subscription: subscription}
    end

    test "successfully list subscriptions" do
      assert {:ok, [%SubscriptionDetails{}], _} = Weddell.subscriptions(max: 1)
    end
  end

  describe "Weddell.topic_subscriptions/2" do
    setup do
      topic = "test-topic-#{UUID.uuid4()}"
      :ok = Weddell.create_topic(topic)
      subscription = "test-subscription-#{UUID.uuid4()}"
      :ok = Weddell.create_subscription(subscription, topic)
      {:ok, topic: topic, subscription: subscription}
    end

    test "successfully list subscriptions for a topic",
    %{topic: topic, subscription: subscription} do
      assert {:ok, [^subscription], _} = Weddell.topic_subscriptions(topic, max: 1)
    end
  end

  describe "Weddell.publish/2" do
    setup do
      topic = "test-topic-#{UUID.uuid4()}"
      :ok = Weddell.create_topic(topic)
      subscription = "test-subscription-#{UUID.uuid4()}"
      :ok = Weddell.create_subscription(subscription, topic)
      {:ok, topic: topic, subscription: subscription}
    end

    test "a message with data", %{topic: topic} do
      assert :ok = Weddell.publish("test-message", topic)
    end

    test "a message with attributes", %{topic: topic} do
      assert :ok = Weddell.publish(%{"foo" => "bar"}, topic)
    end

    test "a message with data and attributes", %{topic: topic} do
      assert :ok = Weddell.publish({"test-message", %{"foo" => "bar"}}, topic)
    end

    test "fail without data or attributes", %{topic: topic} do
      error = %RPCError{message: "Some messages are empty", status: "3"}
      assert {:error, error} == Weddell.publish(nil, topic)
    end
  end

  describe "Weddell.pull/2" do
    setup do
      topic = "test-topic-#{UUID.uuid4()}"
      :ok = Weddell.create_topic(topic)
      subscription = "test-subscription-#{UUID.uuid4()}"
      :ok = Weddell.create_subscription(subscription, topic)
      message = {"test-data", %{"foo" => "bar"}}
      :ok = Weddell.publish(message, topic)
      {:ok, topic: topic, subscription: subscription, message: message}
    end

    test "pull a message with data and attributes",
    %{subscription: subscription, message: message} do
      {data, attributes} = message
      assert {:ok, [%Message{data: ^data, attributes: ^attributes}]} =
        Weddell.pull(subscription, max_messages: 1, return_immediately: false)
    end

    test "fail to pull a message from an invalid subscription" do
      assert {:error, %RPCError{message: "Subscription does not exist", status: "5"}} =
        Weddell.pull("test-subscription-#{UUID.uuid4()}")
    end
  end

  describe "Weddell.acknowledge/2" do
    setup do
      topic = "test-topic-#{UUID.uuid4()}"
      :ok = Weddell.create_topic(topic)
      subscription = "test-subscription-#{UUID.uuid4()}"
      :ok = Weddell.create_subscription(subscription, topic)
      message = {"test-data", %{"foo" => "bar"}}
      :ok = Weddell.publish(message, topic)
      {:ok, [message]} = Weddell.pull(subscription, max_messages: 1, return_immediately: false)
      {:ok, topic: topic, subscription: subscription, message: message}
    end

    test "successfully acknowledge a message",
    %{subscription: subscription, message: message} do
      assert :ok = Weddell.acknowledge(message, subscription)
      assert {:ok, []} = Weddell.pull(subscription, max_messages: 1, return_immediately: true)
    end

    test "fail to ack a message from an invalid subscription", %{message: message} do
      assert {:error, %RPCError{message: "Subscription does not exist", status: "5"}} =
        Weddell.acknowledge(message, "test-subscription-#{UUID.uuid4()}")
    end
  end
end
