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
    children = case Application.get_env(:weddell, :no_connect_on_start, false) do
      true -> []
      false -> [worker(Client, [])]
    end
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Return the client currently connected to Pub/Sub.
  """
  @spec client(timeout :: integer()) :: Client.t
  def client(timeout \\ 5000) do
    Weddell.Client.client(Weddell.Client, timeout)
  end

  @doc """
  Creates a new topic belonging to the configured project.

  ## Examples
      Weddell.create_topic("foo")
      #=> :ok
  """
  @spec create_topic(topic_name :: String.t, timeout :: integer()) :: :ok | error
  def create_topic(name, timeout \\ 5000) do
    Weddell.Client.create_topic(Weddell.Client, name, timeout)
  end

  @doc """
  Deletes a topic belonging to the configured project.

  ## Examples
      Weddell.delete_topic("foo")
      #=> :ok
  """
  @spec delete_topic(topic_name :: String.t, timeout :: integer()) :: :ok | error
  def delete_topic(name, timeout \\ 5000) do
    Weddell.Client.delete_topic(Weddell.Client, name, timeout)
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
  @spec topics(opts :: Client.list_options, timeout :: integer()) ::
    {:ok, topic_names :: [String.t]} |
    {:ok, topic_names :: [String.t], Client.cursor} |
    error
  def topics(opts \\ [], timeout \\ 5000) do
    Weddell.Client.topics(Weddell.Client, opts, timeout)
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
                            Client.subscription_options,
                            timeout :: integer()) ::
    :ok | error
  def create_subscription(name, topic, opts \\ [], timeout \\ 5000) do
    Weddell.Client.create_subscription(Weddell.Client, name, topic, opts, timeout)
  end

  @doc """
  Deletes a subscription belonging to the configured project.

  ## Examples
      Weddell.delete_subscription("foo")
      #=> :ok
  """
  @spec delete_subscription(subscription_name :: String.t, timeout :: integer()) ::
    :ok | error
  def delete_subscription(name, timeout \\ 5000) do
    Weddell.Client.delete_subscription(Weddell.Client, name, timeout)
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
  @spec subscriptions(opts :: Client.list_options, timeout :: integer()) ::
    {:ok, subscriptions :: [SubscriptionDetails.t]} |
    {:ok, subscriptions :: [SubscriptionDetails.t], Client.cursor} |
    error
  def subscriptions(opts \\ [], timeout \\ 5000) do
    Weddell.Client.subscriptions(Weddell.Client, opts, timeout)
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
  @spec topic_subscriptions(topic :: String.t,
                            opts :: Client.list_options,
                            timeout :: integer()) ::
    {:ok, subscriptions :: [String.t]} |
    {:ok, subscriptions :: [String.t], Client.cursor} |
    error
  def topic_subscriptions(topic, opts \\ [], timeout \\ 5000) do
    Weddell.Client.topic_subscriptions(Weddell.Client, topic, opts, timeout)
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
                topic_name :: String.t,
                timeout :: integer()) ::
    :ok | error
  def publish(messages, topic, timeout \\ 5000) do
    Weddell.Client.publish(Weddell.Client, messages, topic, timeout)
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
  @spec pull(subscription_name :: String.t, Client.pull_options,
             timeout :: integer()) ::
    {:ok, messages :: [Message.t]} | error
  def pull(subscription, opts \\ [], timeout \\ 5000) do
    Weddell.Client.pull(Weddell.Client, subscription, opts, timeout)
  end

  @doc """
  Acknowledges messages, removing them from the subscription

  ## Examples

      messages = [%Message{}, %Message{}]
      Weddell.acknowledge(messages, "foo-subscription")
      #=> :ok
  """
  @spec acknowledge(messages :: [Message.t] |  Message.t,
                    subscription_name :: String.t,
                    timeout :: integer()) ::
    :ok | error
  def acknowledge(messages, subscription, timeout \\ 5000) do
    Weddell.Client.acknowledge(Weddell.Client, messages, subscriptions, timeout)
  end
end
