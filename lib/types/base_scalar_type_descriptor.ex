defmodule ExEdgeDb.Types.BaseScalarTypeDescriptor do
  defstruct [
    :id
  ]

  def decode(binary) do
    <<id::binary-size(16)>> = binary

    %__MODULE__{
      id: id
    }
  end
end
