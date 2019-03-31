defmodule Weddell.Consumer do
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
        schedule_listen()

        {:ok, subscription}
      end

      def handle_info(:listen, subscription) do
        stream = new_stream(subscription)

        stream
        |> Subscriber.Stream.recv()
        |> Enum.each(&(dispatch(&1, stream)))

        Subscriber.Stream.close(stream)

        schedule_listen()

        {:noreply, subscription}
      end

      def handle_info(
        {:gun_error, _, _, {:stream_error, :no_error, _}},
        subscription
      ) do
        # Error: Stream reset by server.
        {:stop, :shutdown, subscription}
      end

      def handle_info(
        {:gun_error, _, _, {:badstate, _}},
        subscription
      ) do
        # Error: The stream cannot be found.
        {:stop, :shutdown, subscription}
      end

      def handle_info(type, subscription) do
        Logger.debug "Weddell.Consumer - handle_info/2 unhandled - #{inspect(type)}"

        {:stop, :unknown, subscription}
      end

      defp schedule_listen do
        Process.send_after(self(), :listen, 100)
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
