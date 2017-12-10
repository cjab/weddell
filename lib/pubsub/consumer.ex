defmodule Pubsub.Consumer do
  alias Pubsub.Client
  alias Pubsub.Message
  alias Pubsub.Client.Subscriber

  @typedoc "A list delay tuple"
  @type message_delay :: {Message.t, pos_integer}

  @typedoc "Message handler response option"
  @type response_option :: {:ack, [Message.t]} |
                           {:delay, [message_delay]}

  @typedoc "Option values used when connecting clients"
  @type response_options:: [response_option]

  @callback handle_messages(messages :: [Message.t]) ::
    {:ok, response_options} | :error

  defmacro __using__(_opts) do
    quote do
      @behaviour Pubsub.Consumer

      def child_spec(subscription) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [subscription]},
          restart: :permanent,
          shutdown: 5000,
          type: :worker,
        }
      end

      def start_link(subscription) do
        GenServer.start_link(__MODULE__, [subscription])
      end

      def init(subscription) do
        stream =
          Pubsub.client()
          |> Subscriber.Stream.open(subscription)
        Subscriber.Stream.send(stream)
        GenServer.cast(self(), :listen)
        {:ok, stream}
      end

      def handle_cast(:listen, stream) do
        stream
        |> Subscriber.Stream.recv()
        |> Enum.each(fn (%{received_messages: messages}) ->
          messages
          |> Enum.map(&Message.new/1)
          |> dispatch()
        end)
        {:stop, :stream_closed, stream}
      end

      defp dispatch(messages) do
        case handle_messages(messages) do
          {:ok, opts} ->
            acks = Keyword.get(opts, :ack, [])
            delays = Keyword.get(opts, :delay, [])
            IO.inspect("ACKED: #{inspect acks}")
            IO.inspect("DELAYED: #{inspect delays}")
          _ ->
            IO.inspect("OTHER!")
        end
      end
    end
  end
end
