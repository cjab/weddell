defmodule Pubsub.Message do
  @moduledoc """
  """
  alias Google_Pubsub_V1.PubsubMessage

  @type t :: %__MODULE__{data: binary}
  defstruct [:data]

  def new(%PubsubMessage{data: data}) do
    %__MODULE__{data: data}
  end
end
