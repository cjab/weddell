defmodule Pubsub do
  @moduledoc """
  Documentation for Pubsub.
  """
  use Application

  alias Pubsub.Client
  alias GRPC.RPCError

  @typedoc "WIP: What is this?"
  @type message :: any

  @typedoc "An RPC error"
  @type error :: {:error, RPCError.t}

  @typedoc "Option values used when pulling messages"
  @type pull_option :: {:return_immediately, boolean} |
                       {:max_messages, pos_integer}

  @typedoc "Options used when pulling messages"
  @type pull_options :: [pull_option]

  @typedoc "Option values used when creating a subscription"
  @type subscription_option :: {:ack_deadline, pos_integer} |
                               {:push_endpoint, String.t}

  @typedoc "Options used when creating a subscription"
  @type subscription_options :: [subscription_option]

  @doc """
  """
  def start(_type, _args) do
    import Supervisor.Spec
    children = [worker(Client, [])]
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
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
                            topic_name :: String.t, subscription_options) :: :ok | error
  def create_subscription(name, topic, opts \\ []) do
    GenServer.call(Pubsub.Client, {:create_subscription, name, topic, opts})
  end

  @doc """
  Publish a message to a topic

  ## Examples

      Pubsub.publish("message-data", "foo-topic")
      #=> :ok

  """
  @spec publish(data :: String.t, topic_name :: String.t) ::
    {:ok, message_ids :: [String.t]} | error
  def publish(data, topic) do
    GenServer.call(Pubsub.Client, {:publish, data, topic})
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
  @spec pull(subscription_name :: String.t, pull_options) ::
    {:ok, messages :: [message]} | error
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
end
