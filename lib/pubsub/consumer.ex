defmodule Pubsub.Consumer do
  alias Pubsub.Client
  alias Pubsub.Client.Subscriber

  @callback handle_message(message :: Message.t) ::
    :ack | :retry | {:delay, deadline :: pos_integer}

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
          dispatch(messages)
        end)
        {:stop, :stream_closed, stream}
      end

      defp dispatch(messages) when is_list(messages),
        do: Enum.each(messages, &dispatch/1)
      defp dispatch(%{ack_id: ack_id, message: message}) do
        case handle_message(message) do
          :ack ->
            IO.inspect("ACKED: #{ack_id}")
          :retry ->
            IO.inspect("RETRY: #{ack_id}")
          {:delay, deadline} ->
            IO.inspect("DELAYED: #{ack_id} #{inspect deadline}")
        end
      end
    end
  end
end
