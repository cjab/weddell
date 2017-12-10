defmodule Pubsub.Message do
  @moduledoc """
  """
  alias Google_Pubsub_V1.ReceivedMessage

  @type t :: %__MODULE__{id: String.t,
                         ack_id: String.t,
                         published_at: Datetime.t,
                         attributes: map,
                         data: binary}
  defstruct [:id, :ack_id, :published_at, :attributes, :data]

  def new(%ReceivedMessage{ack_id: ack_id, message: message}) do
    %__MODULE__{id: message.message_id,
                ack_id: ack_id,
                published_at: DateTime.from_unix!(message.publish_time.seconds),
                attributes: attributes_to_map(message.attributes),
                data: message.data}
  end

  defp attributes_to_map(attributes) do
    attributes
    |> Enum.reduce(%{}, fn (%{key: key, value: value}, acc) ->
      Map.put(acc, key, value)
    end)
  end
end
