defmodule Pubsub.Client.Subscriber do
  @moduledoc false
  alias Pubsub.Client
  alias Google_Protobuf.Empty
  alias Google_Pubsub_V1.PushConfig
  alias Google_Pubsub_V1.PullRequest
  alias Google_Pubsub_V1.PullResponse
  alias Google_Pubsub_V1.Subscription
  alias Google_Pubsub_V1.AcknowledgeRequest
  alias Google_Pubsub_V1.ListSubscriptionsRequest
  alias Google_Pubsub_V1.ListSubscriptionsResponse
  alias Google_Pubsub_V1.DeleteSubscriptionRequest
  alias Google_Pubsub_V1.Subscriber.Stub
  alias Pubsub.Client.Util
  alias Pubsub.SubscriptionDetails

  @default_list_max 50

  defp stub_module do
    Application.get_env(:pubsub, :subscriber_stub, Google_Pubsub_V1.Subscriber.Stub)
  end

  @spec create_subscription(Client.t, name :: String.t,
                            topic :: String.t,
                            Client.subscription_options) :: :ok | Client.error
  def create_subscription(client, name, topic, opts \\ []) do
    ack_deadline = Keyword.get(opts, :ack_deadline_seconds, 10)
    push_config = case Keyword.get(opts, :push_endpoint, nil) do
      nil -> nil
      endpoint -> PushConfig.new(push_endpoint: endpoint)
    end
    subscription =
      Subscription.new(
        topic: Util.full_topic(client.project, topic),
        name: Util.full_subscription(client.project, name),
        push_config: push_config,
        ack_deadline_seconds: ack_deadline)
    client.channel
    |> stub_module().create_subscription(subscription, Client.request_opts(client))
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, _subscription} -> :ok
    end
  end

  @spec delete_subscription(Client.t, name :: String.t) :: :ok | Client.error
  def delete_subscription(client, name) do
    request =
      DeleteSubscriptionRequest.new(
        subscription: Util.full_subscription(client.project, name))
    client.channel
    |> stub_module().delete_subscription(request, Client.request_opts(client))
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %Empty{}} -> :ok
    end
  end

  @spec subscriptions(Client.t, Client.list_options) ::
    {:ok, [SubscriptionDetails.t]} |
    {:ok, [SubscriptionDetails.t], Client.cursor} |
    Client.error
  def subscriptions(client, opts \\ []) do
    max_topics = Keyword.get(opts, :max, @default_list_max)
    cursor = Keyword.get(opts, :cursor, "")
    request = ListSubscriptionsRequest.new(project: "projects/#{client.project}",
                                    page_size: max_topics,
                                    page_token: cursor)
    client.channel
    |> stub_module().list_subscriptions(request, Client.request_opts(client))
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %ListSubscriptionsResponse{next_page_token: nil} = response} ->
        details = Enum.map(response.subscriptions, &(SubscriptionDetails.new(&1)))
        {:ok, details}
      {:ok, %ListSubscriptionsResponse{next_page_token: next_cursor} = response} ->
        details = Enum.map(response.subscriptions, &(SubscriptionDetails.new(&1)))
        {:ok, details, next_cursor}
    end
  end

  def pull(client, subscription, opts \\ []) do
    request =
      PullRequest.new(
        subscription: Util.full_subscription(client.project, subscription),
        return_immediately: Keyword.get(opts, :return_immediately, true),
        max_messages: Keyword.get(opts, :max_messages, 1))
    client.channel
    |> Stub.pull(request, Client.request_opts(client))
    |> case do
      {:error, _rpc_error} = error ->
        error
      {:ok, %PullResponse{received_messages: messages}} ->
        {:ok, messages}
    end
  end

  def acknowledge(client, ack_id, subscription) when not is_list(ack_id),
    do: acknowledge(client, [ack_id], subscription)
  def acknowledge(client, ack_ids, subscription) do
    request =
      AcknowledgeRequest.new(
        subscription: Util.full_subscription(client.project, subscription),
        ack_ids: ack_ids)
    client.channel
    |> Stub.acknowledge(request, Client.request_opts(client))
    |> case do
      {:error, _rpc_error} = error -> error
      {:ok, %Empty{}} -> :ok
    end
  end
end
