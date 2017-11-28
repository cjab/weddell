defmodule Pubsub.Client.SubscriberTest do
  use ExUnit.Case
  import Mox
  alias GRPC.RPCError
  alias Google_Protobuf.Empty
  alias Pubsub.Client
  alias Pubsub.Client.Subscriber
  alias Pubsub.Client.Util
  alias Pubsub.SubscriberStubMock

  @project "test-project"
  @topic "test-topic"
  @subscription "test-subscription"

  describe "Subscriber.create_subscription" do
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

  defp setup_client(_) do
    [client: %Client{project: @project}]
  end

  defp stub_create_subscription(_) do
    Application.put_env(:pubsub, :subscriber_stub, SubscriberStubMock)
    SubscriberStubMock
    |> stub(:create_subscription, fn _, _, _ ->
      {:ok, %Empty{}}
    end)
    :ok
  end
end
