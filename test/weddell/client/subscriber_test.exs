defmodule Weddell.Client.SubscriberTest do
  use ExUnit.Case

  import Mox

  alias GRPC.RPCError
  alias Google_Protobuf.Empty
  alias Google_Pubsub_V1.{Subscription,
                          PullResponse,
                          ReceivedMessage,
                          ListSubscriptionsResponse}
  alias Weddell.{Message,
                 Client,
                 Client.Util,
                 Client.Subscriber,
                 SubscriberStubMock,
                 SubscriptionDetails}

  Application.put_env(:weddell, :subscriber_stub, SubscriberStubMock)

  @project "test-project"
  @topic "test-topic"
  @subscription "test-subscription"

  describe "Subscriber.create_subscription/4" do
    setup [:setup_client, :stub_create_subscription, :verify_on_exit!]

    test "create a subscription with a topic and a name", %{client: client} do
      topic = Util.full_topic(@project, @topic)
      name = Util.full_subscription(@project, @subscription)
      SubscriberStubMock
      |> expect(:create_subscription, fn _, %{topic: ^topic, name: ^name}, _ ->
        {:ok, %Empty{}}
      end)
      assert :ok ==
        Subscriber.create_subscription(client, @subscription, @topic)
    end

    test "create a subscription with deadline and push endpoint", %{client: client} do
      push_endpoint = "https://example.org"
      deadline = 99
      SubscriberStubMock
      |> expect(:create_subscription, fn
        (_, %{ack_deadline_seconds: ^deadline, push_config: %{push_endpoint: ^push_endpoint}}, _) ->
          {:ok, %Empty{}}
      end)
      assert :ok ==
        Subscriber.create_subscription(client,
                                       @subscription, @topic,
                                       ack_deadline_seconds: deadline,
                                       push_endpoint: push_endpoint)
    end

    test "error creating a subscription", %{client: client} do
      error = %RPCError{}
      SubscriberStubMock
      |> expect(:create_subscription, fn _, _, _ ->
        {:error, error}
      end)
      assert {:error, error} ==
        Subscriber.create_subscription(client, @subscription, @topic)
    end
  end

  describe "Subscriber.delete_subscription/2" do
    setup [:setup_client, :stub_delete_subscription, :verify_on_exit!]

    test "delete a subscription", %{client: client} do
      subscription = Util.full_subscription(@project, @subscription)
      SubscriberStubMock
      |> expect(:delete_subscription, fn _, %{subscription: ^subscription}, _ ->
        {:ok, %Empty{}}
      end)
      assert :ok ==
        Subscriber.delete_subscription(client, @subscription)
    end

    test "error deleting a subscription", %{client: client} do
      error = %RPCError{}
      SubscriberStubMock
      |> expect(:delete_subscription, fn _, _, _ ->
        {:error, error}
      end)
      assert {:error, error} ==
        Subscriber.delete_subscription(client, @subscription)
    end
  end

  describe "Subscriber.subscriptions/2" do
    setup [:setup_client, :stub_list_subscriptions, :verify_on_exit!]

    test "list all subscriptions without paging", %{client: client} do
      project = Util.full_project(client.project)
      subscription = %Subscription{push_config: %{push_endpoint: nil, attributes: nil},
                                   name: Util.full_subscription(@project, @subscription),
                                   topic: Util.full_topic(@project, @topic)}
      subscriptions = [subscription, subscription]
      SubscriberStubMock
      |> expect(:list_subscriptions, fn
        (_, %{project: ^project, page_size: 50}, _) ->
          {:ok, %ListSubscriptionsResponse{subscriptions: subscriptions}}
      end)
      assert {:ok, [%SubscriptionDetails{}, %SubscriptionDetails{}]} =
        Subscriber.subscriptions(client)
    end

    test "list all subscriptions with paging", %{client: client} do
      project = Util.full_project(client.project)
      subscription = %Subscription{push_config: %{push_endpoint: nil, attributes: nil},
                                   name: Util.full_subscription(@project, @subscription),
                                   topic: Util.full_topic(@project, @topic)}
      subscriptions = [subscription, subscription]
      cursor = "page-token"
      max = 100
      SubscriberStubMock
      |> expect(:list_subscriptions, fn
        (_, %{project: ^project, page_token: ^cursor, page_size: ^max}, _) ->
          {:ok,
            %ListSubscriptionsResponse{subscriptions: subscriptions,
                                       next_page_token: cursor}}
      end)
      assert {:ok, [%SubscriptionDetails{}, %SubscriptionDetails{}], ^cursor} =
        Subscriber.subscriptions(client, cursor: cursor, max: max)
    end

    test "error listing subscriptions", %{client: client} do
      error = %RPCError{}
      SubscriberStubMock
      |> expect(:list_subscriptions, fn _, _, _ ->
        {:error, error}
      end)
      assert {:error, error} ==
        Subscriber.subscriptions(client)
    end
  end

  describe "Subscriber.pull/3" do
    setup [:setup_client, :stub_pull, :verify_on_exit!]

    test "successfully pulls messages", %{client: client} do
      subscription = Util.full_subscription(client.project, @subscription)
      message = %{message_id: "1", publish_time: %{seconds: 1}, attributes: %{}, data: ""}
      SubscriberStubMock
      |> expect(:pull, fn
        (_, %{subscription: ^subscription}, _) ->
          {:ok, %PullResponse{received_messages: [%ReceivedMessage{message: message},
                                                  %ReceivedMessage{message: message}]}}
      end)
      assert {:ok, [%Message{}, %Message{}]} =
        Subscriber.pull(client, @subscription)
    end

    test "successfully pulls messages with options", %{client: client} do
      message = %{message_id: "1", publish_time: %{seconds: 1}, attributes: %{}, data: ""}
      SubscriberStubMock
      |> expect(:pull, fn
        (_, %{return_immediately: false, max_messages: 50}, _) ->
          {:ok, %PullResponse{received_messages: [%ReceivedMessage{message: message},
                                                  %ReceivedMessage{message: message}]}}
      end)
      assert {:ok, [%Message{}, %Message{}]} =
        Subscriber.pull(client, @subscription, return_immediately: false, max_messages: 50)
    end

    test "error pulling messages", %{client: client} do
      error = %RPCError{}
      SubscriberStubMock
      |> expect(:pull, fn _, _, _ ->
          {:error, error}
      end)
      assert {:error, error} ==
        Subscriber.pull(client, @subscription)
    end
  end

  describe "Subscriber.acknowledge/3" do
    setup [:setup_client, :stub_acknowledge, :verify_on_exit!]

    test "successfully acks messages", %{client: client} do
      subscription = Util.full_subscription(client.project, @subscription)
      messages = [%Message{ack_id: "ack-1"}, %Message{ack_id: "ack-2"}]
      ack_ids = Enum.map(messages, &(&1.ack_id))
      SubscriberStubMock
      |> expect(:acknowledge, fn
        (_, %{subscription: ^subscription, ack_ids: ^ack_ids}, _) ->
          {:ok, %Empty{}}
      end)
      assert :ok ==
        Subscriber.acknowledge(client, messages, @subscription)
    end

    test "successfully acks single message", %{client: client} do
      subscription = Util.full_subscription(client.project, @subscription)
      ack_id = "ack-1"
      message = %Message{ack_id: ack_id}
      SubscriberStubMock
      |> expect(:acknowledge, fn
        (_, %{subscription: ^subscription, ack_ids: [^ack_id]}, _) ->
          {:ok, %Empty{}}
      end)
      assert :ok ==
        Subscriber.acknowledge(client, message, @subscription)
    end

    test "error acking messages", %{client: client} do
      error = %RPCError{}
      message = %Message{ack_id: "ack-1"}
      SubscriberStubMock
      |> expect(:acknowledge, fn _, _, _ ->
          {:error, error}
      end)
      assert {:error, error} ==
        Subscriber.acknowledge(client, message, @subscription)
    end
  end

  defp setup_client(_) do
    [client: %Client{project: @project}]
  end

  defp stub_create_subscription(_) do
    SubscriberStubMock
    |> stub(:create_subscription, fn _, _, _ ->
      {:ok, %Empty{}}
    end)
    :ok
  end

  defp stub_delete_subscription(_) do
    SubscriberStubMock
    |> stub(:delete_subscription, fn _, _, _ ->
      {:ok, %Empty{}}
    end)
    :ok
  end

  defp stub_list_subscriptions(_) do
    SubscriberStubMock
    |> stub(:list_subscriptions, fn _, _, _ ->
      {:ok, %Empty{}}
    end)
    :ok
  end

  defp stub_pull(_) do
    SubscriberStubMock
    |> stub(:pull, fn _, _, _ ->
      {:ok, []}
    end)
    :ok
  end

  defp stub_acknowledge(_) do
    SubscriberStubMock
    |> stub(:acknowledge, fn _, _, _ ->
      {:ok, %Empty{}}
    end)
    :ok
  end
end
