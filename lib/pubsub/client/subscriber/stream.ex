defmodule Pubsub.Client.Subscriber.Stream do
  alias Pubsub.Client
  alias Pubsub.Client.Util
  alias Google_Pubsub_V1.Subscriber.Stub
  alias Google_Pubsub_V1.Subscriber.StreamingPullRequest
  alias Google_Pubsub_V1.Subscriber.StreamingPullResponse

  @typedoc "A pubsub subscriber stream"
  @opaque t :: %__MODULE{client: Pubsub.Client.t,
                         grpc_stream: GRPC.Client.Stream.t}
  defstruct [:client, :grpc_stream]

  @default_ack_deadline 10

  @spec open(Client.t) :: t
  def open(client) do
    %__MODULE__{client: client,
                grpc_stream: Stub.streaming_pull(client.channel)}
  end

  @spec close(t) :: :ok
  def close(stream) do
    request =
      StreamingPullRequest.new(
        subscription: Util.full_subscription(stream.client.project, subscription))
    GRPC.Stub.stream_send(stream.grpc_stream, request, end_stream: true)
  end

  @typedoc "An ack id and a new deadline in seconds"
  @type deadline :: {ack_id :: String.t, seconds :: pos_integer}

  @typedoc "Option values used when writing to a stream"
  @type send_opt :: {:ack, ack_ids :: [String.t]} |
                      {:modify_deadline, [deadline]} |
                      {:stream_deadline, seconds :: pos_integer}

  @typedoc "Options used when writing to a stream"
  @type send_opts :: [send_opt]

  @spec send(stream :: t, subscription :: String.t, send_opts) :: :ok
  def send(stream, subscription, opts \\ [])  do
    {deadline_ack_ids, deadline_seconds} =
      opts
      |> Keyword.get(:modify_deadline, [])
      |> Enum.reduce({[], []}, fn ({id, deadline}, {ids, deadlines}) ->
        {[id | ids], [deadline | deadlines]}
      end
    request =
      StreamingPullRequest.new(
        subscription: Util.full_subscription(stream.client.project, subscription),
        ack_ids: Keyword.get(opts, :ack, []),
        modify_deadline_ack_ids: deadline_ack_ids,
        modify_deadline_seconds: deadline_seconds,
        stream_ack_deadline_seconds: Keyword.get(opts,
                                                 :stream_ack_deadline_seconds,
                                                 @default_ack_deadline))
    GRPC.Stub.stream_send(stream.grpc_stream, request)
  end

  @spec recv(stream :: t) :: Enumerable.t
  def recv(stream) do
    GRPC.Stub.recv(stream.grpc_stream)
  end
end
