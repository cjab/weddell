defmodule Weddell do
  @moduledoc """
  Documentation for Weddell.
  """
  use Application

  alias GRPC.RPCError
  alias Weddell.{Message,
                 Client,
                 Client.Publisher,
                 SubscriptionDetails}

  @typedoc "An RPC error"
  @type error :: {:error, RPCError.t}

  @doc """
  Start Weddell and connect to the Pub/Sub server.
  """
  def start(_type, _args) do
    import Supervisor.Spec
    children = [worker(Client, [])]
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Return the client currently connected to Pub/Sub.
  """
  @spec client() :: Client.t
  def client do
    GenServer.call(Weddell.Client, {:client})
  end

  @doc """
  Creates a new topic belonging to the configured project.

  ## Examples
      Weddell.create_topic("foo")
      #=> :ok
  """
  @spec create_topic(topic_name :: String.t) :: :ok | error
  def create_topic(name) do
    GenServer.call(Weddell.Client, {:create_topic, name})
  end

  @doc """
  Deletes a topic belonging to the configured project.

  ## Examples
      Weddell.delete_topic("foo")
      #=> :ok
  """
  @spec delete_topic(topic_name :: String.t) :: :ok | error
  def delete_topic(name) do
    GenServer.call(Weddell.Client, {:delete_topic, name})
  end

  @doc """
  List topics belonging to the configured project.

  ## Examples

      Weddell.topics(max: 50)
      #=> {:ok, ["foo", "bar", ...]}

  When more topics exist:

      Weddell.topics(max: 1)
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
    GenServer.call(Weddell.Client, {:topics, opts})
  end

  @doc """
  Creates a new subscription belonging to the topic and
  the configured project.

  ## Examples

      Weddell.create_subscription("foo-subscription", "foo-topic", ack_deadline: 10)
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
    GenServer.call(Weddell.Client, {:create_subscription, name, topic, opts})
  end

  @doc """
  Deletes a subscription belonging to the configured project.

  ## Examples
      Weddell.delete_subscription("foo")
      #=> :ok
  """
  @spec delete_subscription(subscription_name :: String.t) :: :ok | error
  def delete_subscription(name) do
    GenServer.call(Weddell.Client, {:delete_subscription, name})
  end

  @doc """
  List subscription details belonging to the configured project.

  ## Examples

      Weddell.subscriptions(max: 50)
      #=> {:ok, [%SubscriptionDetails{}, %SubscriptionDetails{}, ...]}

  When more subscriptions exist:

      Weddell.subscriptions(max: 1)
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
    GenServer.call(Weddell.Client, {:subscriptions, opts})
  end

  @doc """
  List subscriptions belonging to a topic.

  ## Examples

      Weddell.topic_subscriptions("foo-topic", max: 50)
      #=> {:ok, ["foo-subscription", "bar-subscription", ...]}

  When more subscriptions exist:

      Weddell.topic_subscriptions("foo-topic", max: 1)
      #=> {:ok, ["foo-subscription"], "list-cursor"}

  ## Options

    * `:max` - The maximum number of subscriptions to return fromn a single request.
      If more subscriptions exist make another call using the returned cursor.
      _(default: 50)_
    * `:cursor` - List subscriptions starting at a cursor returned by an earlier call.
      _(default: nil)_
  """
  @spec topic_subscriptions(topic :: String.t, opts :: Client.list_options) ::
    {:ok, subscriptions :: [String.t]} |
    {:ok, subscriptions :: [String.t], Client.cursor} |
    error
  def topic_subscriptions(topic, opts \\ []) do
    GenServer.call(Weddell.Client, {:topic_subscriptions, topic, opts})
  end

  @doc """
  Publish message or messages to a topic.

  ## Examples

      ### Data only

      "message-data"
      |> Weddell.publish("foo-topic")
      #=> :ok

      ### Data and attributes

      {"message-data", %{"foo" => "bar"}}
      |> Weddell.publish("foo-topic")
      #=> :ok

      ### Attributes only

      %{"foo" => "bar"}
      |> Weddell.publish("foo-topic")
      #=> :ok

      ### A list of messages (data and attributes)

      [{"message-data-1", %{"foo" => "bar"}},
       {"message-data-2", %{"foo" => "bar"}}]
      |> Weddell.publish("foo-topic")

  """
  @spec publish(Publisher.new_message | [Publisher.new_message],
                topic_name :: String.t) :: :ok | error
  def publish(messages, topic) do
    GenServer.call(Weddell.Client, {:publish, messages, topic})
  end

  @doc """
  Pulls messages from a subscription

  ## Examples

      Weddell.pull("foo-subscription", return_immediately: true, max_messages: 10)
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
    GenServer.call(Weddell.Client, {:pull, subscription, opts})
  end

  @doc """
  Acknowledges messages, removing them from the subscription

  ## Examples

      messages = [%Message{}, %Message{}]
      Weddell.acknowledge(messages, "foo-subscription")
      #=> :ok
  """
  @spec acknowledge(messages :: [Message.t] | message :: Message.t,
                    subscription_name :: String.t) :: :ok | error
  def acknowledge(messages, subscription) do
    GenServer.call(Weddell.Client, {:acknowledge, messages, subscription})
  end
end
