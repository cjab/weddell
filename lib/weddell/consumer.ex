defmodule Weddell.Consumer do
  alias GRPC.RPCError

  alias Weddell.{Message,
                 Client.Subscriber}

  @typedoc "Message handler response option"
  @type response_option :: {:ack, [Message.t]} |
                           {:delay, [Subscriber.Stream.message_delay]}

  @typedoc "Option values used when connecting clients"
  @type response_options:: [response_option]

  @callback handle_messages(messages :: [Message.t]) ::
    {:ok, response_options} | :error

  defmacro __using__(_opts) do
    quote do
      require Logger
      @behaviour Weddell.Consumer

      @deadline_expired 4

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
        GenServer.cast self(), :listen

        {:ok, subscription}
      end

      def handle_cast(:listen, subscription) do
        stream = new_stream(subscription)

        stream
        |> Subscriber.Stream.recv()
        |> case do
          {:error, e} = error ->
            Logger.error(e)
            error
          batches ->
            Enum.each(batches, fn
              {:ok, messages} ->
                dispatch(messages, stream)
              {:error, %RPCError{status: @deadline_expired} = error} ->
                # Deadline expired and stream ended, this is expected
                []
              {:error, e} = error ->
                Logger.error(e)
                error
            end)
        end

        GenServer.cast self(), :listen

        {:noreply, subscription}
      end

      defp new_stream(subscription) do
        Weddell.client()
        |> Subscriber.Stream.open(subscription)
      end

      defp dispatch(messages, stream) do
        case handle_messages(messages) do
          {:ok, opts} ->
            stream
            |> Subscriber.Stream.send(opts)
        end
      end
    end
  end
end
