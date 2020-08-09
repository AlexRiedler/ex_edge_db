defmodule ExEdgeDb.Types.TupleElement do
  defstruct [
    :name,
    :type_pos
  ]

  def decode(binary) do
    <<name_length::size(32), name::binary-size(name_length), type_pos::signed-size(16)>> = binary

    %__MODULE__{
      name: name,
      type_pos: type_pos
    }
  end
end
