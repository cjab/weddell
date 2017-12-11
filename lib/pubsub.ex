defmodule Pubsub do
  @moduledoc """
  Documentation for Pubsub.
  """
  use Application

  alias Pubsub.Client
  alias Pubsub.Message
  alias Pubsub.Client.Publisher
  alias Pubsub.Client.Subscriber.Stream
  alias GRPC.RPCError

  @typedoc "An RPC error"
  @type error :: {:error, RPCError.t}

  @doc """
  """
  def start(_type, _args) do
    import Supervisor.Spec
    children = [worker(Client, [])]
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  @doc """
  """
  @spec client() :: Client.t
  def client do
    GenServer.call(Pubsub.Client, {:client})
  end

  @doc """
  Creates a new topic belonging to the configured project.

  ## Examples
      Pubsub.create_topic("foo")
      #=> :ok
  """
  @spec create_topic(topic_name :: String.t) :: :ok | error
  def create_topic(name) do
    GenServer.call(Pubsub.Client, {:create_topic, name})
  end

  @doc """
  Deletes a topic belonging to the configured project.

  ## Examples
      Pubsub.delete_topic("foo")
      #=> :ok
  """
  @spec delete_topic(topic_name :: String.t) :: :ok | error
  def delete_topic(name) do
    GenServer.call(Pubsub.Client, {:delete_topic, name})
  end

  @doc """
  List topics belonging to the configured project.

  ## Examples

      Pubsub.topics(max: 50)
      #=> {:ok, ["foo", "bar", ...]}

  When more topics exist:

      Pubsub.topics(max: 1)
      #=> {:ok, ["foo"], "list-cursor"}

  ## Options

    * `:max` - The maximum number of topics to return fromn a single request.
      If more topics exist make another call using the returned cursor.
      _(default: 50)_
    * `:cursor` - List topics starting at a cursor returned by an earlier call.
      _(default: nil)_
  """
  @spec topics(opts :: Client.list_options) ::
    {:ok, topic_names :: [String.t]} |
    {:ok, topic_names :: [String.t], Client.cursor} |
    error
  def topics(opts \\ []) do
    GenServer.call(Pubsub.Client, {:topics, opts})
  end

  @doc """
  Creates a new subscription belonging to the topic and
  the configured project.

  ## Examples

      Pubsub.create_subscription("foo-subscription", "foo-topic", ack_deadline: 10)
      #=> :ok

  ## Options

    * `:ack_deadline` - The maximum amount of time in seconds after receiving a message before
      a message expires. If this deadline passes without the message being acked it
      can be pulled again. If this is a push subscription this configures the timeout
      for the push to the endpoint. The minimum value is 10 seconds and the max 600 seconds.
      _(default: 10)_
    * `:push_endpoint` - If this option is set messages will be automatically pushed
      to the specified URL. For example, a Webhook endpoint might
      use "https://example.com/push". _(default: nil)_
  """
  @spec create_subscription(subscription_name :: String.t,
                            topic_name :: String.t,
                            Client.subscription_options) :: :ok | error
  def create_subscription(name, topic, opts \\ []) do
    GenServer.call(Pubsub.Client, {:create_subscription, name, topic, opts})
  end

  @doc """
  Deletes a subscription belonging to the configured project.

  ## Examples
      Pubsub.delete_subscription("foo")
      #=> :ok
  """
  @spec delete_subscription(subscription_name :: String.t) :: :ok | error
  def delete_subscription(name) do
    GenServer.call(Pubsub.Client, {:delete_subscription, name})
  end

  @doc """
  List subscription details belonging to the configured project.

  ## Examples

      Pubsub.subscriptions(max: 50)
      #=> {:ok, [%SubscriptionDetails{}, %SubscriptionDetails{}, ...]}

  When more subscriptions exist:

      Pubsub.subscriptions(max: 1)
      #=> {:ok, [%SubscriptionDetails{}], "list-cursor"}

  ## Options

    * `:max` - The maximum number of subscriptions to return fromn a single request.
      If more subscriptions exist make another call using the returned cursor.
      _(default: 50)_
    * `:cursor` - List subscriptions starting at a cursor returned by an earlier call.
      _(default: nil)_
  """
  @spec subscriptions(opts :: Client.list_options) ::
    {:ok, subscriptions :: [SubscriptionDetails.t]} |
    {:ok, subscriptions :: [SubscriptionDetails.t], Client.cursor} |
    error
  def subscriptions(opts \\ []) do
    GenServer.call(Pubsub.Client, {:subscriptions, opts})
  end

  @doc """
  Publish message or messages to a topic.

  ## Examples

      ### Data only

      "message-data"
      |> Pubsub.publish("foo-topic")
      #=> :ok

      ### Data and attributes

      {"message-data", %{"foo" => "bar"}}
      |> Pubsub.publish("foo-topic")
      #=> :ok

      ### Attributes only

      %{"foo" => "bar"}
      |> Pubsub.publish("foo-topic")
      #=> :ok

      ### A list of messages (data and attributes)

      [{"message-data-1", %{"foo" => "bar"}},
       {"message-data-2", %{"foo" => "bar"}}]
      |> Pubsub.publish("foo-topic")

  """
  @spec publish(Publisher.new_message | [Publisher.new_message],
                topic_name :: String.t) :: :ok | error
  def publish(messages, topic) do
    GenServer.call(Pubsub.Client, {:publish, messages, topic})
  end

  @doc """
  Pulls messages from a subscription

  ## Examples

      Pubsub.pull("foo-subscription", return_immediately: true, max_messages: 10)
      #=> {:ok, [%Message{}]}

  ## Options

    * `:return_immediately` - If set to true, pull will return immediately even
      if there are no messages available to return. Otherwise, pull may wait
      (for a bounded amount of time) until at least one message is available,
      rather than returning no messages. _(default: true)_
    * `:max_messages` - The maximum number of messages to be returned,
      it may be fewer. _(default: 10)_
  """
  @spec pull(subscription_name :: String.t, Client.pull_options) ::
    {:ok, messages :: [Message.t]} | error
  def pull(subscription, opts \\ []) do
    GenServer.call(Pubsub.Client, {:pull, subscription, opts})
  end

  @doc """
  Acknowledges messages, removing them from the subscription

  ## Examples

      ack_ids = ["projects/project/subscriptions/foo:1",
                 "projects/project/subscriptions/foo:2"]
      Pubsub.acknowledge(ack_ids, "foo-subscription")
      #=> :ok
  """
  @spec acknowledge(ack_ids :: [String.t], subscription_name :: String.t) :: :ok | error
  def acknowledge(ack_ids, subscription) do
    GenServer.call(Pubsub.Client, {:acknowledge, ack_ids, subscription})
  end

  @doc """
  Starts a streaming pull for the given subscription

  ## Examples

      Pubsub.open_stream("foo-subscription")
      #=> %Stream{}
  """
  @spec open_stream(subscription_name :: String.t) :: Stream.t
  def open_stream(subscription) do
    GenServer.call(Pubsub.Client, {:open_stream, subscription})
  end
end
