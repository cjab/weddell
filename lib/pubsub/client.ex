defmodule Pubsub.Client do
  @moduledoc """
  A persistent process responsible for interacting with Pusub over GRPC.
  """
  use GenServer

  alias GRPC.Stub
  alias GRPC.RPCError
  alias Pubsub.Client.Publisher
  alias Pubsub.Client.Subscriber

  @default_host "pubsub.googleapis.com"
  @default_port 443

  @typedoc "A pubsub client"
  @opaque t :: %__MODULE__{channel: GRPC.Channel.t,
                           project: String.t}

  defstruct [:channel, :project]

  @typedoc "An RPC error"
  @type error :: {:error, RPCError.t}

  @typedoc "Option value used when connecting a client"
  @type connect_option :: {:host, String.t} |
                          {:port, pos_integer} |
                          {:scheme, :http | :https} |
                          {:ssl, [:ssl.ssl_option]}

  @typedoc "Option values used when connecting clients"
  @type connect_options :: [connect_option]

  @typedoc "Option values used when creating a subscription"
  @type subscription_option :: {:ack_deadline, pos_integer} |
                               {:push_endpoint, String.t}

  @typedoc "Options used when creating a subscription"
  @type subscription_options :: [subscription_option]

  @typedoc "Option value used when retrieving lists"
  @type list_option :: {:max, pos_integer} |
                       {:cursor, cursor}

  @typedoc "Option values used when retrieving lists"
  @type list_options :: [list_option]

  @typedoc "Option values used when pulling messages"
  @type pull_option :: {:return_immediately, boolean} |
                       {:max_messages, pos_integer}

  @typedoc "Options used when pulling messages"
  @type pull_options :: [pull_option]

  @typedoc "Option values used when publishing messages"
  @type publish_option :: {:attributes, %{optional(String.t) => String.t}}

  @typedoc "Options used when publishing messages"
  @type publish_options :: [publish_option]

  @typedoc "A cursor used for pagination of lists"
  @type cursor :: String.t

  @doc """
  Start the client process and connect to Pubsub using settings in the application config.

  ## Example

  In your application config:

      config :pubsub,
        scheme: :http,
        host: "localhost",
        port: 8085,
        project: "test-project"

  ## Settings

    * `project` - The __required__ Google Cloud project that will be used for all calls made by this client.
    * `scheme` - The scheme to use when connecting to the pubsub service. _(default: :https)_
    * `host` - The pubsub host to connect to. This defaults to Google's pubsub service but
      is useful for connecting to a local pubsub emulator _(default: "pubsub.googleapis.com")_
    * `port` - The port on which to connect to the host. _(default: 443)_
    * `ssl` - SSL settings to be used when connecting with the `:https` scheme. See `ssl_option()`
      in the [ssl documentation] (http://erlang.org/doc/man/ssl.html).
      _(default: [:cacerts: :certifi.cacerts()])_
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    connect(Application.get_env(:pubsub, :project),
            Application.get_all_env(:pubsub))
  end

  @doc """
  Connect to a pubsub server and return a client.

  ## Example

      Pubsub.Client.connect("project-name",
                            scheme: :https,
                            host: "pubsub.googleapis.com",
                            port: 443,
                            ssl: [cacerts: :certifi.cacerts()])
      #=> {:ok, client}

  ## Options

    * `scheme` - The scheme to use when connecting to the pubsub service. _(default: :https)_
    * `host` - The pubsub host to connect to. This defaults to Google's pubsub service but
      is useful for connecting to a local pubsub emulator _(default: "pubsub.googleapis.com")_
    * `port` - The port on which to connect to the host. _(default: 443)_
    * `ssl` - SSL settings to be used when connecting with the `:https` scheme. See `ssl_option()`
      in the [ssl documentation](http://erlang.org/doc/man/ssl.html).
      _(default: [cacerts: :certifi.cacerts()])_
  """
  @spec connect(project :: String.t, opts :: connect_options) :: {:ok, t}
  def connect(project, opts \\ []) do
    scheme = Keyword.get(opts, :scheme, :https)
    ssl = ssl_opts(opts)
    cred = if scheme == :https, do: GRPC.Credential.new(ssl: ssl), else: nil
    host = Keyword.get(opts, :host, @default_host)
    port = Keyword.get(opts, :port, @default_port)
    {:ok, channel} =
      Stub.connect("#{host}:#{port}", cred: cred)
    {:ok, %__MODULE__{channel: channel,
                      project: project}}
  end

  @spec request_opts(client :: t) :: Keyword.t
  def request_opts(_client) do
    [metadata: auth_header(), content_type: "application/grpc"]
  end

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
      {:create_subscription, name, topic, opts} ->
        {:reply, Subscriber.create_subscription(client, name, topic, opts), client}
      {:delete_subscription, name} ->
        {:reply, Subscriber.delete_subscription(client, name), client}
      {:subscriptions, opts} ->
        {:reply, Subscriber.subscriptions(client, opts), client}
      {:pull, subscription, opts} ->
        {:reply, Subscriber.pull(client, subscription, opts), client}
      {:acknowledge, ack_ids, subscription} ->
        {:reply, Subscriber.acknowledge(client, ack_ids, subscription), client}
      {:client} ->
        {:reply, client, client}
    end
  end

  def handle_info(_, client) do
    {:noreply, client}
  end

  defp auth_header do
    {:ok, %{token: token, type: token_type}} =
      Goth.Token.for_scope("https://www.googleapis.com/auth/pubsub")
    %{"authorization" => "#{token_type} #{token}"}
  end

  defp ssl_opts(opts) do
    default_opts = [cacerts: :certifi.cacerts()]
    ssl_opts = Keyword.get(opts, :ssl, [])
    default_opts
    |> Keyword.merge(ssl_opts)
  end
end
