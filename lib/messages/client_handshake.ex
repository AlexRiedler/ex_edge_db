defmodule ExEdgeDB.Messages.ClientHandshake do
  alias ExEdgeDB.Messages.{ConnectionParam, ProtocolExtension}

  import ExEdgeDB.Messages.Utils

  defstruct [
    :major_version,
    :minor_version,
    # ConnectionParams
    :params,
    # ProtocolExtension
    :extensions,
  ]

  def encode(%{major_version: major_version, minor_version: minor_version, params: params, extensions: extensions}) do
    mtype = encode_uint(?V, 8)
    IO.inspect(mtype)
    major_ver = encode_uint(major_version, 16)
    minor_ver = encode_uint(minor_version, 16)
    num_params = encode_uint(length(params), 16)
    {x, encoded_params} =
      Enum.reduce(params, {0, <<>>}, fn param, {acc_size, acc_message} ->
        {size, message} = ConnectionParam.encode(param)
        {acc_size + size, acc_message <> message}
      end)
    num_extensions = encode_uint(length(extensions), 16)
    {y, encoded_extensions} = 
      Enum.reduce(extensions, {0, <<>>}, fn extension, {acc_size, acc_message} ->
        {size, message} = ProtocolExtension.encode(extension)
        {acc_size + size, acc_message <> message}
      end)

    message_length = 4 + 2 + 2 + 2 + x + 2 + y
    message_length_encoded = encode_uint(message_length, 32)
    bytes = mtype <> message_length_encoded <> major_ver <> minor_ver <> num_params <> encoded_params <> num_extensions <> encoded_extensions
    IO.inspect(bytes)

    {message_length, bytes}
  end
end

defmodule ExEdgeDB.Messages.ConnectionParam do
  defstruct [:name, :value]

  import ExEdgeDB.Messages.Utils

  def encode(%{name: name, value: value}) do
    {name_bytes, encoded_name} = encode_string(name)
    {value_bytes, encoded_value} = encode_string(value)
    bytes = name_bytes + value_bytes
    {bytes, encoded_name <> encoded_value}
  end
end

defmodule ExEdgeDB.Messages.ProtocolExtension do
  alias ExEdgeDB.Messages.Header

  import ExEdgeDB.Messages.Utils

  defstruct [:name, :headers]
  def encode(%{name: name, headers: headers}) do
    {name_bytes, encoded_name} = encode_string(name)
    num_headers = encode_uint(length(headers), 16)
    {headers_bytes, encoded_headers} = 
      headers |> Enum.reduce({0, <<>>}, fn header, {acc_size, acc_message} ->
        {size, message} = Header.encode(header)
        {size + acc_size, acc_message <> message}
      end)

    bytes = name_bytes + 2 + headers_bytes
    {bytes, encoded_name <> num_headers <> encoded_headers}
  end
end

defmodule ExEdgeDB.Messages.Header do
  defstruct [:code, :value]

  import ExEdgeDB.Messages.Utils

  def encode(%{code: code, value: value}) do
    encoded_code = encode_uint(code, 16)
    {encoded_value_bytes, encoded_value} = encode_bytes(value)
    bytes = 2 + encoded_value_bytes

    {bytes, encoded_code <> encoded_value}
  end
end

defmodule ExEdgeDB.Messages.ServerHandshake do
  alias ExEdgeDB.Messages.{ProtocolExtension}

  defstruct [:major_version, :minor_version, :extensions]

  import ExEdgeDB.Messages.Utils

  def encode(%{major_version: major_version, minor_version: minor_version, extensions: extensions}) do
    mtype = encode_uint(?v, 8)
    major_ver = encode_uint(major_version, 16)
    minor_ver = encode_uint(minor_version, 16)
    num_extensions = encode_uint(length(extensions), 16)
    {y, encoded_extensions} = 
      Enum.reduce({0, <<>>}, fn extension, {acc_size, acc_message} ->
        {size, message} = ProtocolExtension.encode(extension)
        {acc_size + size, acc_message <> message}
      end)

    message_length = 4 + 2 + 2 + 2 + y
    message_length_encoded = encode_uint(32, message_length)
    bytes = mtype <> message_length_encoded <> major_ver <> minor_ver <> num_extensions <> encoded_extensions

    {message_length, bytes}
  end

  def decode(bin) do
    # todo
    bin
  end
end
