defmodule Weddell.Client.Subscriber.Stream do
  @moduledoc """
  A streaming connection to a subscription.
  """
  alias GRPC.Client.Stream, as: GRPCStream
  alias GRPC.RPCError
  alias GRPC.Stub, as: GRPCStub
  alias Google.Pubsub.V1.{Subscriber.Stub,
                          StreamingPullRequest}
  alias Weddell.{Message,
                 Client,
                 Client.Util}

  @typedoc "A Pub/Sub subscriber stream"
  @opaque t :: %__MODULE__{client: Client.t,
                           subscription: String.t,
                           grpc_stream: GRPCStream.t}
  defstruct [:client, :subscription, :grpc_stream]

  @default_ack_deadline 10
  @deadline_expired 4

  @doc """
  Open a new stream on a subscription.

  Streams can be used to pull new messages from a subscription and also
  respond with acknowledgements or delays.

  ## Example

      {:ok, client} = Weddell.Client.connect("weddell-project")
      Weddell.Client.Subscriber.Stream.open(client, "foo-subscription")
      #=> %Weddell.Client.Subscriber.Stream{}
  """
  @spec open(Client.t, subscription :: String.t) :: t
  def open(client, subscription) do
    stream =
      %__MODULE__{client: client,
                  subscription: subscription,
                  grpc_stream: Stub.streaming_pull(client.channel, Client.request_opts())}
    request =
      StreamingPullRequest.new(subscription: Util.full_subscription(client.project, subscription),
                               stream_ack_deadline_seconds: @default_ack_deadline)
    stream.grpc_stream
    |> GRPCStub.send_request(request)
    stream
  end

  @doc """
  Close an open stream.

  ## Example

      {:ok, client} = Weddell.Client.connect("weddell-project")
      stream = Weddell.Client.Subscriber.Stream.open(client, "foo-subscription")
      Weddell.Client.Subscriber.Stream.close(stream)
      #=> :ok
  """
  @spec close(t) :: :ok
  def close(stream) do
    request =
      StreamingPullRequest.new(
        subscription: Util.full_subscription(stream.client.project, stream.subscription))
    GRPCStub.send_request(stream.grpc_stream, request, end_stream: true)
  end

  @typedoc "A message and a new deadline in seconds"
  @type message_delay :: {Message.t, seconds :: pos_integer}

  @typedoc "Option values used when writing to a stream"
  @type send_opt :: {:ack, [Message.t]} |
                    {:delay, [message_delay]} |
                    {:stream_deadline, seconds :: pos_integer}

  @typedoc "Options used when writing to a stream"
  @type send_opts :: [send_opt]

  @doc """
  Send a response to a stream.

  ## Example

      {:ok, client} = Weddell.Client.connect("weddell-project")
      stream = Weddell.Client.Subscriber.Stream.open(client, "foo-subscription")
      Weddell.Client.Subscriber.Stream.send(stream,
                                            ack: [%Message{}],
                                            delay: [{%Message{}, 60}],
                                            stream_deadline: 120)

      #=> :ok

  ## Options

    * `ack` - Messages to be acknowledged. _(default: [])_
    * `delay` - Messages to be delayed and the period for which to delay. _(default: [])_
    * `stream_deadline` - The time period to wait before resending a
       message on this stream. _(default: 10)_
  """
  @spec send(stream :: t, send_opts) :: :ok
  def send(stream, opts \\ [])  do
    ack_ids =
      opts
      |> Keyword.get(:ack, [])
      |> Enum.map(&(&1.ack_id))
    {deadline_ack_ids, deadline_seconds} =
      opts
      |> Keyword.get(:delay, [])
      |> Enum.reduce({[], []}, fn ({message, seconds}, {ids, deadlines}) ->
        {[message.ack_id | ids], [seconds | deadlines]}
      end)
    stream_deadline =
      opts
      |> Keyword.get(:stream_deadline, @default_ack_deadline)
    request =
      StreamingPullRequest.new(
        ack_ids: ack_ids,
        modify_deadline_ack_ids: deadline_ack_ids,
        modify_deadline_seconds: deadline_seconds,
        stream_ack_deadline_seconds: stream_deadline)
    GRPCStub.send_request(stream.grpc_stream, request)
  end

  @doc """
  Receive messages from a stream.

  ## Example

      {:ok, client} = Weddell.Client.connect("weddell-project")
      client
      |> Weddell.Client.Subscriber.Stream.open("foo-subscription")
      |> Weddell.Client.Subscriber.Stream.recv()
      |> Enum.take(1)
      #=> [%Message{...}]
  """
  @spec recv(stream :: t) :: Enumerable.t
  def recv(stream) do
    case GRPCStub.recv(stream.grpc_stream) do
      {:ok, recv} ->
        recv
        |> Stream.map(fn
          {:ok, response} ->
            Enum.map(response.received_messages, &Message.new/1)
          {:error, %RPCError{status: @deadline_expired}} ->
            # Deadline expired and stream ended, this is expected
            []
          {:error, e} ->
            raise e
        end)
      {:error, e} ->
        raise e
    end
  end
end
