defmodule ExEdgeDb.Types.ShapeElement do
  defstruct [
    :flags,
    :name,
    :type_pos
  ]

  def decode(binary) do
    <<flags::size(8), name_length::size(32), name::binary-size(name_length), type_pos::size(16)>> = binary

    %__MODULE__{
      flags: flags,
      name: name,
      type_pos: type_pos
    }
  end
end
