defmodule Pubsub.Client.Subscriber.Stream do
  alias Pubsub.Client
  alias Pubsub.Client.Util
  alias Google_Pubsub_V1.Subscriber.Stub
  alias Google_Pubsub_V1.StreamingPullRequest
  alias Google_Pubsub_V1.StreamingPullResponse

  @typedoc "A pubsub subscriber stream"
  @opaque t :: %__MODULE__{client: Pubsub.Client.t,
                           subscription: String.t,
                           grpc_stream: GRPC.Client.Stream.t}
  defstruct [:client, :subscription, :grpc_stream]

  @default_ack_deadline 10

  @spec open(Client.t, subscription :: String.t) :: t
  def open(client, subscription) do
    stream =
      %__MODULE__{client: client,
                  subscription: subscription,
                  grpc_stream: Stub.streaming_pull(client.channel, Client.request_opts(client))}
    request =
      StreamingPullRequest.new(subscription: Util.full_subscription(client.project, subscription),
                               stream_ack_deadline_seconds: @default_ack_deadline)
    stream.grpc_stream
    |> GRPC.Stub.stream_send(request)
    stream
  end

  @spec close(t) :: :ok
  def close(stream) do
    request =
      StreamingPullRequest.new(
        subscription: Util.full_subscription(stream.client.project, stream.subscription))
    GRPC.Stub.stream_send(stream.grpc_stream, request, end_stream: true)
  end

  @typedoc "A message and a new deadline in seconds"
  @type message_delay :: {Message.t, seconds :: pos_integer}

  @typedoc "Option values used when writing to a stream"
  @type send_opt :: {:ack, [Message.t]} |
                    {:delay, [message_delay]} |
                    {:stream_deadline, seconds :: pos_integer}

  @typedoc "Options used when writing to a stream"
  @type send_opts :: [send_opt]

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
    GRPC.Stub.stream_send(stream.grpc_stream, request)
  end

  @spec recv(stream :: t) :: Enumerable.t
  def recv(stream) do
    GRPC.Stub.recv(stream.grpc_stream)
  end
end
