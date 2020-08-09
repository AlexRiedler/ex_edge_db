defmodule ExEdgeDb.Types.ObjectShapeDescriptor do
  defstruct [
    :id,
    :elements
  ]

  def decode(binary) do
    <<id::binary-size(16), element_count::size(16), elements_binary::binary>> = binary
    {elements, _} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Types.ShapeElement, element_count, elements_binary)

    %__MODULE__{
      id: id,
      elements: elements
    }
  end
end
