defmodule ExEdgeDb.Types.TypeAnnotationDescriptor do
  defstruct [
    :id,
    :annotation
  ]

  def decode(binary) do
    <<id::binary-size(16), annotation_length::size(16), annotation::binary-size(annotation_length)>> = binary

    %__MODULE__{
      id: id,
      annotation: annotation
    }
  end
end
