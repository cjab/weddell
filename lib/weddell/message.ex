defmodule Weddell.Message do
  @moduledoc """
  """
  alias Google_Pubsub_V1.ReceivedMessage

  @type t :: %__MODULE__{id: String.t,
                         ack_id: String.t,
                         published_at: DateTime.t,
                         attributes: map,
                         data: binary}
  defstruct [:id, :ack_id, :published_at, :attributes, :data]

  def new(%ReceivedMessage{ack_id: ack_id, message: message}) do
    %__MODULE__{id: message.message_id,
                ack_id: ack_id,
                published_at: DateTime.from_unix!(message.publish_time.seconds),
                attributes: message.attributes,
                data: message.data}
  end
end
