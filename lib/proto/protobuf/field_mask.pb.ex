defmodule Google_Protobuf.FieldMask do
  @moduledoc false
  use Protobuf

  @type t :: %__MODULE__{
    paths: [String.t]
  }
  defstruct [:paths]

  field :paths, 1, repeated: true, type: :string
end
