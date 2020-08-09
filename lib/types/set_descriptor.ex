defmodule ExEdgeDb.Types.SetDescriptor do
  defstruct [
    :id,
    :type_pos
  ]

  def decode(binary) do
    <<id::binary-size(16), type_pos::size(16)>> = binary

    %__MODULE__{
      id: id,
      type_pos: type_pos
    }
  end
end
