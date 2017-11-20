defmodule Pubsub.Client do
  @moduledoc """
  A persistent process responsible for interacting with Pusub over GRPC.
  """
  use GenServer

  alias GRPC.Stub
  alias Pubsub.Client.Publisher
  alias Pubsub.Client.Subscriber

  @default_host "pubsub.googleapis.com"
  @default_port 443

  @typedoc "A pubsub client"
  @opaque t :: {GRPC.Channel.t, project :: String.t}

  @typedoc "An RPC error"
  @type error :: {:error, RPCError.t}

  @typedoc "Option value used when connecting a client"
  @type connect_option :: {:host, String.t} |
                          {:port, pos_integer} |
                          {:ca_path, String.t}

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

  @typedoc "A cursor used for pagination of lists"
  @type cursor :: String.t

  defstruct [:channel, :project, :request_opts]

  @doc """
  Start the client process and connect to Pubsub using settings in the application config.

  ## Example

  In your application config:

      config :pubsub,
        host: "localhost",
        port: 8085,
        ca_path: "/usr/local/etc/openssl/cert.pem",
        project: "test-project"

  ## Settings

    * `project` - The __required__ Google Cloud project that will be used for all calls made by this client.
    * `host` - The pubsub host to connect to. This defaults to Google's pubsub service but
      is useful for connecting to a local pubsub emulator _(default: "pubsub.googleapis.com")_
    * `port` - The port on which to connect to the host. _(default: 443)_
    * `ca_path` - The path to a pem formatted ca cert chain. _(default: nil)_
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    connect(Application.get_env(:pubsub, :project),
      ca_path: Application.get_env(:pubsub, :ca_path),
      host: Application.get_env(:pubsub, :host),
      port: Application.get_env(:pubsub, :port))
  end

  @doc """
  Connect to a pubsub server and return a client.

  ## Example

      Pubsub.Client.connect("project-name",
                            host: "pubsub.googleapis.com",
                            port: 443,
                            ca_path: "/usr/local/etc/openssl/cert.pem")
      #=> {:ok, client}

  ## Options

    * `host` - The pubsub host to connect to. This defaults to Google's pubsub service but
      is useful for connecting to a local pubsub emulator _(default: "pubsub.googleapis.com")_
    * `port` - The port on which to connect to the host. _(default: 443)_
    * `ca_path` - The path to a pem formatted ca cert chain. _(default: nil)_
  """
  @spec connect(project :: String.t, opts :: connect_options) :: {:ok, t}
  def connect(project, opts \\ []) do
    ca_path = Keyword.get(opts, :ca_path)
    cred = if ca_path, do: GRPC.Credential.client_tls(ca_path), else: nil
    host = Keyword.get(opts, :host) || @default_host
    port = Keyword.get(opts, :port) || @default_port
    {:ok, channel} =
      Stub.connect("#{host}:#{port}", cred: cred)
    {:ok, %__MODULE__{channel: channel,
                      project: project,
                      request_opts: request_opts()}}
  end

  def handle_call(request, _, client) do
    client = %{client | request_opts: request_opts()}
    case request do
      {:create_topic, name} ->
        {:reply, Publisher.create_topic(client, name), client}
      {:delete_topic, name} ->
        {:reply, Publisher.delete_topic(client, name), client}
      {:topics, opts} ->
        {:reply, Publisher.topics(client, opts), client}
      {:publish, data, topic} ->
        {:reply, Publisher.publish(client, data, topic), client}
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
    end
  end

  def handle_info(_, client) do
    {:noreply, client}
  end

  defp request_opts do
    [metadata: auth_header(), content_type: "application/grpc"]
  end

  defp auth_header do
    {:ok, %{token: token, type: token_type}} =
      Goth.Token.for_scope("https://www.googleapis.com/auth/pubsub")
    %{"authorization" => "#{token_type} #{token}"}
  end
end
