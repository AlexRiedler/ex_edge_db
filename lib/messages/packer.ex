defprotocol ExEdgeDB.Messages.Packer do
  def pack(term) 
  def bytesize(term)
end

defimpl ExEdgeDB.Messages.Packer, for: BitString do
  import ExEdgeDB.Messages.Utils

  def pack(binary) when is_binary(binary) do
    size = bytesize(binary)
    {size, encode_uint(size - 4, 32) <> binary}
  end

  def bytesize(binary) when is_binary(binary) do
    4 + byte_size(binary)
  end
end

defimpl ExEdgeDB.Messages.Packer, for: List do
  def pack(list) do
    Enum.reduce(list, {0, <<>>}, fn elem, {acc_size, acc_message} ->
      {size, message} = ExEdgeDB.Messages.Packer.pack(elem)
      {acc_size + size, acc_message <> message}
    end)
  end

  def bytesize(list) do
    Enum.reduce(list, 0, fn elem, acc_size ->
      acc_size + ExEdgeDB.Messages.Packer.bytesize(elem)
    end)
  end
end

defimpl ExEdgeDB.Messages.Packer, for: Tuple do
  def pack(tuple) do
    case tuple do
      {module, value} -> module.encode(value)
      _ ->
        raise("Unhandled Tuple Packing")
    end
  end

  def bytesize(tuple) do
    case tuple do
      {module, value} -> module.bytesize(value)
      _ ->
        raise("Unhandled Tuple Packing")
    end
  end
end

defimpl ExEdgeDB.Messages.Packer, for: Any do
  def pack(msg) do
    Enum.reduce(msg.__struct__.encoding(msg), {0, ""}, fn elem, {acc_size, acc_message} ->
      {size, message} = ExEdgeDB.Messages.Packer.pack(elem)
      {acc_size + size, acc_message <> message}
    end)
  end

  def bytesize(msg) do
    Enum.reduce(msg.__struct__.encoding(msg), 0, fn elem, acc_size ->
      acc_size + ExEdgeDB.Messages.Packer.bytesize(elem)
    end)
  end
end
