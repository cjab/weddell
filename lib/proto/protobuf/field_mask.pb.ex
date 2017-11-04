defmodule Google_Protobuf.FieldMask do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    paths: [String.t]
  }
  defstruct [:paths]

  field :paths, 1, repeated: true, type: :string
end
