defmodule ExEdgeDb.Messages.ClientHandshake do
  @derive [ExEdgeDb.Messages.Packer]
  defstruct [
    :major_version,
    :minor_version,
    # ConnectionParams
    :params,
    # ProtocolExtension
    :extensions,
  ]

  def encoding(%__MODULE__{major_version: major_version, minor_version: minor_version, params: params, extensions: extensions}) do
    message_body = [
      ExEdgeDb.Messages.UInt16.new(major_version),
      ExEdgeDb.Messages.UInt16.new(minor_version),
      ExEdgeDb.Messages.UInt16.new(length(params)),
      params,
      ExEdgeDb.Messages.UInt16.new(length(extensions)),
      extensions,
    ]

    message_length = ExEdgeDb.Messages.Packer.bytesize(message_body)
    _test = ExEdgeDb.Messages.Packer.pack(message_body)

    [ExEdgeDb.Messages.UInt8.new(?V), ExEdgeDb.Messages.UInt32.new(message_length + 4)] ++ message_body
  end

  def decode(binary) do
    <<_mtype::size(8), _message_length::size(32), major_version::size(16), minor_version::size(16), param_count::size(16), rs::binary>> = binary
    {params, rss} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Messages.ConnectionParam, param_count, rs)
    <<extension_count::size(16), rsss::binary>> = rss
    {extensions, rsss} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Messages.ProtocolExtension, extension_count, rsss)

    {
      %__MODULE__{
        major_version: major_version,
        minor_version: minor_version,
        params: params,
        extensions: extensions
      },
      rsss
    }
    end
end

defmodule ExEdgeDb.Messages.ConnectionParam do
  @derive [ExEdgeDb.Messages.Packer]
  defstruct [:name, :value]

  def encoding(%__MODULE__{name: name, value: value}) do
    [
      name,
      value
    ]
  end

  def decode(binary) do
    {name, rs} = ExEdgeDb.Messages.Utils.decode_string(binary)
    {value, rss} = ExEdgeDb.Messages.Utils.decode_string(rs)
    {%__MODULE__{name: name, value: value}, rss}
  end
end

defmodule ExEdgeDb.Messages.ProtocolExtension do
  @derive [ExEdgeDb.Messages.Packer]
  defstruct [:name, :headers]

  def encoding(%__MODULE__{name: name, headers: headers}) do
    [
      name,
      ExEdgeDb.Messages.UInt32.new(length(headers)),
      headers
    ]
  end

  def decode(binary) do
    {name, remaining} = ExEdgeDb.Messages.Utils.decode_string(binary)
    <<length::size(32), remains::binary>> = remaining
    {headers, last} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Messages.Header, length, remains)
    {%__MODULE__{name: name, headers: headers}, last}
  end
end

defmodule ExEdgeDb.Messages.Header do
  @derive [ExEdgeDb.Messages.Packer]
  defstruct [:code, :value]

  def encoding(%__MODULE__{code: code, value: value}) do
    [
      ExEdgeDb.Messages.UInt16.new(code),
      value
    ]
  end

  def decode(binary) do
    <<code::size(16), remaining::binary>> = binary
    {value, remains} = ExEdgeDb.Messages.Utils.decode_string(remaining)
    {%__MODULE__{code: code, value: value}, remains}
  end
end

