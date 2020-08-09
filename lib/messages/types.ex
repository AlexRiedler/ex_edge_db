# TODO: bound the new methods, to the valid int ranges
defmodule ExEdgeDb.Messages.Int8 do
  def new(value) do
    {__MODULE__, value}
  end

  def signed? do
    true
  end

  def bitsize do
    8
  end

  def bytesize(_) do
    1
  end

  def encode(value) do
    {__MODULE__.bitsize / 8 |> round, ExEdgeDb.Messages.Utils.encode_int(value, __MODULE__.bitsize)}
  end
end

defmodule ExEdgeDb.Messages.Int16 do
  def new(value) do
    {__MODULE__, value}
  end

  def signed? do
    true
  end

  def bitsize do
    16
  end

  def bytesize(_) do
    2
  end

  def encode(value) do
    {__MODULE__.bitsize / 8 |> round, ExEdgeDb.Messages.Utils.encode_int(value, __MODULE__.bitsize)}
  end
end

defmodule ExEdgeDb.Messages.Int32 do
  def new(value) do
    {__MODULE__, value}
  end

  def signed? do
    true
  end

  def bitsize do
    32
  end

  def bytesize(_) do
    4
  end

  def encode(value) do
    {__MODULE__.bitsize / 8 |> round, ExEdgeDb.Messages.Utils.encode_int(value, __MODULE__.bitsize)}
  end
end

defmodule ExEdgeDb.Messages.UInt8 do
  def new(value) do
    {__MODULE__, value}
  end

  def signed? do
    false
  end

  def bitsize do
    8
  end

  def bytesize(_) do
    1
  end

  def encode(value) do
    {__MODULE__.bitsize / 8 |> round, ExEdgeDb.Messages.Utils.encode_uint(value, __MODULE__.bitsize)}
  end
end

defmodule ExEdgeDb.Messages.UInt16 do
  def new(value) do
    {__MODULE__, value}
  end

  def signed? do
    false
  end

  def bitsize do
    16
  end

  def bytesize(_) do
    2
  end

  def encode(value) do
    {__MODULE__.bitsize / 8 |> round, ExEdgeDb.Messages.Utils.encode_uint(value, __MODULE__.bitsize)}
  end
end

defmodule ExEdgeDb.Messages.UInt32 do
  def new(value) do
    {__MODULE__, value}
  end

  def signed? do
    false
  end

  def bitsize do
    32
  end

  def bytesize(_) do
    4
  end

  def encode(value) do
    {__MODULE__.bitsize / 8 |> round, ExEdgeDb.Messages.Utils.encode_uint(value, __MODULE__.bitsize)}
  end
end

defmodule ExEdgeDb.Messages.Uuid do
  def new(value) do
    {__MODULE__, value}
  end

  def signed? do
    false
  end

  def bitsize do
    128
  end

  def bytesize(_) do
    16
  end

  def encode(value) do
    {__MODULE__.bitsize / 8 |> round, ExEdgeDb.Messages.Utils.encode_uint(value, __MODULE__.bitsize)}
  end
end
