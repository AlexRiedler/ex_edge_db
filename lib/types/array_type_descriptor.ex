defmodule ExEdgeDb.Types.ArrayTypeDescriptor do
  defstruct [
    :id,
    :type_pos,
    :dimension_count,
    :dimensions
  ]

  def decode(binary) do
    <<id::binary-size(16), type_pos::size(16), dimension_count::size(16), dimensions_binary::binary>> = binary
    {dimensions, _} = decode_dimensions(dimensions_binary, dimension_count)

    %__MODULE__{
      id: id,
      type_pos: type_pos,
      dimensions: dimensions
    }
  end

  defp decode_dimensions(dimensions_binary, 0) do
    {[], dimensions_binary}
  end
  defp decode_dimensions(dimensions_binary, dimension_count) do
    {dimensions, rest} =
      Enum.reduce(1..dimension_count, {[], dimensions_binary}, fn _, {acc, binary} ->
        <<dimension_type::size(32), remaining::binary>> = binary
        {[dimension_type | acc], remaining}
      end)
    {Enum.reverse(dimensions), rest}
  end
end
