defmodule ExEdgeDb.Types.ScalarTypeDescriptor do
  defstruct [
    :id,
    :base_type_pos
  ]

  def decode(binary) do
    <<id::binary-size(16), base_type_pos::size(16)>> = binary

    %__MODULE__{
      id: id,
      base_type_pos: base_type_pos
    }
  end
end
