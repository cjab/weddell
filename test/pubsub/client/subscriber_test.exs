defmodule Pubsub.Client.SubscriberTest do
  use ExUnit.Case
  import Mox
  alias GRPC.RPCError
  alias Google_Protobuf.Empty
  alias Google_Pubsub_V1.ListSubscriptionsResponse
  alias Google_Pubsub_V1.Subscription
  alias Pubsub.Client
  alias Pubsub.Client.Subscriber
  alias Pubsub.Client.Util
  alias Pubsub.SubscriptionDetails
  alias Pubsub.SubscriberStubMock

  Application.put_env(:pubsub, :subscriber_stub, SubscriberStubMock)

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
      subscription = %Subscription{push_config: %{push_endpoint: nil, attributes: nil}}
      subscriptions = [subscription, subscription]
      SubscriberStubMock
      |> expect(:list_subscriptions, fn
        (_, %{project: ^project, page_size: 50}, _) ->
          {:ok, %ListSubscriptionsResponse{subscriptions: subscriptions}}
      end)
      assert {:ok, [%SubscriptionDetails{}, %SubscriptionDetails{}]} ==
        Subscriber.subscriptions(client)
    end

    test "list all subscriptions with paging", %{client: client} do
      project = Util.full_project(client.project)
      subscription = %Subscription{push_config: %{push_endpoint: nil, attributes: nil}}
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
      assert {:ok, [%SubscriptionDetails{}, %SubscriptionDetails{}], cursor} ==
        Subscriber.subscriptions(client, cursor: cursor, max: max)
    end

    test "error deleting a subscription", %{client: client} do
      error = %RPCError{}
      SubscriberStubMock
      |> expect(:list_subscriptions, fn _, _, _ ->
        {:error, error}
      end)
      assert {:error, error} ==
        Subscriber.subscriptions(client)
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
end
