defmodule ExEdgeDb.Types.TupleTypeDescriptor do
  defstruct [
    :id,
    :element_count,
    :element_types
  ]

  def decode(binary) do
    <<id::binary-size(16), element_count::size(16), elements_binary::binary>> = binary
    {element_types, _} = decode_element_types(elements_binary, element_count)

    %__MODULE__{
      id: id,
      element_count: element_count,
      element_types: element_types
    }
  end

  defp decode_element_types(elements_binary, 0) do
    {[], elements_binary}
  end
  defp decode_element_types(elements_binary, element_count) do
    {types, rest} =
      Enum.reduce(1..element_count, {[], elements_binary}, fn _, {acc, binary} ->
        <<element_type::size(16), remaining::binary>> = binary
        {[element_type | acc], remaining}
      end)
    {Enum.reverse(types), rest}
  end
end
