defmodule ExEdgeDb.Messages.Utils do

  def decode_string(data) do
    <<length::size(32), remaining::binary>> = data
    bits = length * 8
    <<str::bitstring-size(bits), remains::binary>> = remaining
    {str, remains}
  end

  def decode_list(_module, 0, data) do
    {[], data}
  end
  def decode_list(module, length, data) do
    {xs, remaining} = Enum.reduce(1..length, {[], data}, fn _, {list, binary} ->
      {elem, remains} = module.decode(binary)
      {[elem | list], remains}
    end)
    {Enum.reverse(xs), remaining}
  end

  def encode_uint(data, size_in_bits) when rem(size_in_bits, 8) == 0 do
    size_in_bytes = (size_in_bits / 8) |> round
    bin = maybe_encode_unsigned(data)

    if byte_size(bin) > size_in_bytes do
      raise("Data overflow encoding uint, data `#{data}` cannot fit in #{size_in_bits} bits")
    end

    bin |> pad(size_in_bytes, :left)
  end

  def encode_int(data, size_in_bits) when rem(size_in_bits, 8) == 0 do
    if signed_overflow?(data, size_in_bits) do
      raise("Data overflow encoding int, data `#{data}` cannot fit in #{size_in_bits} bits")
    end

    <<data::signed-size(size_in_bits)>>
  end

  defp signed_overflow?(num, max_bits) do
    num < :math.pow(2, max_bits - 1) * -1 + 1 || num > :math.pow(2, max_bits - 1) - 1
  end

  def pad(bin, size_in_bytes, direction) do
    total_size = size_in_bytes
    padding_size_bits = (total_size - byte_size(bin)) * 8
    padding = <<0::size(padding_size_bits)>>

    case direction do
      :left -> padding <> bin
      :right -> bin <> padding
    end
  end

  def mod(x, n) when x > 0, do: rem x, n
  def mod(x, n) when x < 0, do: rem n + x, n
  def mod(0, _n), do: 0

  defp maybe_encode_unsigned(bin) when is_binary(bin), do: bin
  defp maybe_encode_unsigned(int) when is_integer(int), do: :binary.encode_unsigned(int)
end
