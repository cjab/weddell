defmodule Weddell.Client do
  require Logger

  @moduledoc """
  A persistent process responsible for interacting with Pusub over GRPC.
  """
  use GenServer

  alias GRPC.{Stub, RPCError}
  alias Weddell.Client.{Publisher, Subscriber}

  @default_host "pubsub.googleapis.com"
  @default_port 443

  @typedoc "A Weddell client"
  @type t :: %__MODULE__{channel: GRPC.Channel.t(), project: String.t()}

  defstruct [:channel, :project]

  @typedoc "An RPC error"
  @type error :: {:error, RPCError.t()}

  @typedoc "Option value used when connecting a client"
  @type connect_option ::
          {:host, String.t()}
          | {:port, pos_integer}
          | {:scheme, :http | :https}
          | {:ssl, [:ssl.ssl_option()]}

  @typedoc "Option values used when connecting clients"
  @type connect_options :: [connect_option]

  @typedoc "Option values used when creating a subscription"
  @type subscription_option ::
          {:ack_deadline, pos_integer}
          | {:push_endpoint, String.t()}

  @typedoc "Options used when creating a subscription"
  @type subscription_options :: [subscription_option]

  @typedoc "Option value used when retrieving lists"
  @type list_option ::
          {:max, pos_integer}
          | {:cursor, cursor}

  @typedoc "Option values used when retrieving lists"
  @type list_options :: [list_option]

  @typedoc "Option values used when pulling messages"
  @type pull_option ::
          {:return_immediately, boolean}
          | {:max_messages, pos_integer}

  @typedoc "Options used when pulling messages"
  @type pull_options :: [pull_option]

  @typedoc "Option values used when publishing messages"
  @type publish_option :: {:attributes, %{optional(String.t()) => String.t()}}

  @typedoc "Options used when publishing messages"
  @type publish_options :: [publish_option]

  @typedoc "A cursor used for pagination of lists"
  @type cursor :: String.t()

  @doc """
  Start the client process and connect to Pub/Sub using settings in the application config.

  ## Example

  In your application config:

      config :weddell,
        scheme: :http,
        host: "localhost",
        port: 8085,
        project: "test-project"

  ## Settings

    * `project` - The __required__ Google Cloud project that will be used for all calls made by this client.
    * `scheme` - The scheme to use when connecting to the Pub/Sub service. _(default: :https)_
    * `host` - The Pub/Sub host to connect to. This defaults to Google's Pub/Sub service but
      is useful for connecting to a local Pub/Sub emulator _(default: "pubsub.googleapis.com")_
    * `port` - The port on which to connect to the host. _(default: 443)_
    * `ssl` - SSL settings to be used when connecting with the `:https` scheme. See `ssl_option()`
      in the [ssl documentation] (http://erlang.org/doc/man/ssl.html).
      _(default: [:cacerts: :certifi.cacerts()])_
    * `no_connect_on_start` - By default Weddell will start a client and connect on application start.
      When `true` a client will not be started. Clients can then be started with `Weddell.Client.start_link/3`. _(default: false)_
  """
  def start_link do
    project = Application.get_env(:weddell, :project)
    options = Application.get_all_env(:weddell)
    start_link(project, options, name: __MODULE__)
  end

  def start_link(project, options, gen_server_options \\ []) do
    GenServer.start_link(__MODULE__, [project, options], gen_server_options)
  end

  @spec client(server :: GenServer.server(), timeout :: integer()) :: Client.t()
  def client(server, timeout \\ 5000) do
    GenServer.call(server, {:client}, timeout)
  end

  @spec create_topic(server :: GenServer.server(), topic_name :: String.t(), timeout :: integer()) ::
          :ok | error
  def create_topic(server, name, timeout \\ 5000) do
    GenServer.call(server, {:create_topic, name}, timeout)
  end

  @spec delete_topic(server :: GenServer.server(), topic_name :: String.t(), timeout :: integer()) ::
          :ok | error
  def delete_topic(server, name, timeout \\ 5000) do
    GenServer.call(server, {:delete_topic, name}, timeout)
  end

  @spec topics(server :: GenServer.server(), opts :: Client.list_options(), timeout :: integer()) ::
          {:ok, topic_names :: [String.t()]}
          | {:ok, topic_names :: [String.t()], Client.cursor()}
          | error
  def topics(server, opts \\ [], timeout \\ 5000) do
    GenServer.call(server, {:topics, opts}, timeout)
  end

  @spec create_subscription(
          server :: GenServer.server(),
          subscription_name :: String.t(),
          topic_name :: String.t(),
          Client.subscription_options(),
          timeout :: integer()
        ) ::
          :ok | error
  def create_subscription(server, name, topic, opts \\ [], timeout \\ 5000) do
    GenServer.call(server, {:create_subscription, name, topic, opts}, timeout)
  end

  @spec delete_subscription(
          server :: GenServer.server(),
          subscription_name :: String.t(),
          timeout :: integer()
        ) ::
          :ok | error
  def delete_subscription(server, name, timeout \\ 5000) do
    GenServer.call(server, {:delete_subscription, name}, timeout)
  end

  @spec subscriptions(
          server :: GenServer.server(),
          opts :: Client.list_options(),
          timeout :: integer()
        ) ::
          {:ok, subscriptions :: [SubscriptionDetails.t()]}
          | {:ok, subscriptions :: [SubscriptionDetails.t()], Client.cursor()}
          | error
  def subscriptions(server, opts \\ [], timeout \\ 5000) do
    GenServer.call(server, {:subscriptions, opts}, timeout)
  end

  @spec topic_subscriptions(
          server :: GenServer.server(),
          topic :: String.t(),
          opts :: Client.list_options(),
          timeout :: integer()
        ) ::
          {:ok, subscriptions :: [String.t()]}
          | {:ok, subscriptions :: [String.t()], Client.cursor()}
          | error
  def topic_subscriptions(server, topic, opts \\ [], timeout \\ 5000) do
    GenServer.call(server, {:topic_subscriptions, topic, opts}, timeout)
  end

  @spec publish(
          server :: GenServer.server(),
          Publisher.new_message() | [Publisher.new_message()],
          topic_name :: String.t(),
          timeout :: integer()
        ) ::
          :ok | error
  def publish(server, messages, topic, timeout \\ 5000) do
    GenServer.call(server, {:publish, messages, topic}, timeout)
  end

  @spec pull(
          server :: GenServer.server(),
          subscription_name :: String.t(),
          Client.pull_options(),
          timeout :: integer()
        ) ::
          {:ok, messages :: [Message.t()]} | error
  def pull(server, subscription, opts \\ [], timeout \\ 5000) do
    GenServer.call(server, {:pull, subscription, opts}, timeout)
  end

  @spec acknowledge(
          server :: GenServer.server(),
          messages :: [Message.t()] | Message.t(),
          subscription_name :: String.t(),
          timeout :: integer()
        ) ::
          :ok | error
  def acknowledge(server, messages, subscription, timeout \\ 5000) do
    GenServer.call(server, {:acknowledge, messages, subscription}, timeout)
  end

  def init([project, options]) do
    connect(project, options)
  end

  @doc """
  Connect to a Pub/Sub server and return a client.

  ## Example

      Weddell.Client.connect("project-name",
                            scheme: :https,
                            host: "pubsub.googleapis.com",
                            port: 443,
                            ssl: [cacerts: :certifi.cacerts()])
      #=> {:ok, client}

  ## Options

    * `scheme` - The scheme to use when connecting to the Pub/Sub service. _(default: :https)_
    * `host` - The Pub/Sub host to connect to. This defaults to Google's Pub/Sub service but
      is useful for connecting to a local Pub/Sub emulator _(default: "pubsub.googleapis.com")_
    * `port` - The port on which to connect to the host. _(default: 443)_
    * `ssl` - SSL settings to be used when connecting with the `:https` scheme. See `ssl_option()`
      in the [ssl documentation](http://erlang.org/doc/man/ssl.html).
      _(default: [cacerts: :certifi.cacerts()])_
  """
  @spec connect(project :: String.t(), opts :: connect_options) :: {:ok, t}
  def connect(project, opts \\ []) do
    scheme = Keyword.get(opts, :scheme, :https)
    ssl = ssl_opts(opts)
    cred = if scheme == :https, do: GRPC.Credential.new(ssl: ssl), else: nil
    host = Keyword.get(opts, :host, @default_host)
    port = Keyword.get(opts, :port, @default_port)

    {:ok, channel} =
      Stub.connect("#{host}:#{port}",
        cred: cred,
        adapter_opts: %{
          http2_opts: %{keepalive: :infinity}
        }
      )

    {:ok, %__MODULE__{channel: channel, project: project}}
  end

  @doc false
  @spec request_opts() :: Keyword.t()
  def request_opts(extra_opts \\ []) do
    [metadata: auth_header()]
    |> Enum.concat(extra_opts)
  end

  @doc false
  def handle_call(request, _, client) do
    case request do
      {:create_topic, name} ->
        {:reply, Publisher.create_topic(client, name), client}

      {:delete_topic, name} ->
        {:reply, Publisher.delete_topic(client, name), client}

      {:topics, opts} ->
        {:reply, Publisher.topics(client, opts), client}

      {:publish, messages, topic} ->
        {:reply, Publisher.publish(client, messages, topic), client}

      {:topic_subscriptions, topic, opts} ->
        {:reply, Publisher.topic_subscriptions(client, topic, opts), client}

      {:create_subscription, name, topic, opts} ->
        {:reply, Subscriber.create_subscription(client, name, topic, opts), client}

      {:delete_subscription, name} ->
        {:reply, Subscriber.delete_subscription(client, name), client}

      {:subscriptions, opts} ->
        {:reply, Subscriber.subscriptions(client, opts), client}

      {:pull, subscription, opts} ->
        {:reply, Subscriber.pull(client, subscription, opts), client}

      {:acknowledge, messages, subscription} ->
        {:reply, Subscriber.acknowledge(client, messages, subscription), client}

      {:client} ->
        {:reply, client, client}
    end
  end

  @doc false
  def handle_info(_, client) do
    {:noreply, client}
  end

  defp auth_header do
    if Code.ensure_compiled?(Goth.Token) and not Application.get_env(:goth, :disabled, false) do
      case Goth.Token.for_scope("https://www.googleapis.com/auth/pubsub") do
        {:ok, %{token: token, type: token_type}} ->
          %{"authorization" => "#{token_type} #{token}"}

        _ ->
          %{}
      end
    else
      %{}
    end
  rescue
    # FIXME: This is an ugly way to handle bad gcp credentials
    _ in MatchError ->
      Logger.warn("Bad GCP Credentials, could not retrieve token")
      %{}
  end

  defp ssl_opts(opts) do
    default_opts = [cacerts: :certifi.cacerts()]
    ssl_opts = Keyword.get(opts, :ssl, [])

    default_opts
    |> Keyword.merge(ssl_opts)
  end
end
