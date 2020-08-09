defmodule ExEdgeDB.Messages.ClientHandshake do
  @derive [ExEdgeDB.Messages.Packer]
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
      ExEdgeDB.Messages.UInt16.new(major_version),
      ExEdgeDB.Messages.UInt16.new(minor_version),
      ExEdgeDB.Messages.UInt16.new(length(params)),
      params,
      ExEdgeDB.Messages.UInt16.new(length(extensions)),
      extensions,
    ]

    message_length = ExEdgeDB.Messages.Packer.bytesize(message_body)
    _test = ExEdgeDB.Messages.Packer.pack(message_body)

    [ExEdgeDB.Messages.UInt8.new(?V), ExEdgeDB.Messages.UInt32.new(message_length + 4)] ++ message_body
  end

  def decode(binary) do
    <<_mtype::size(8), _message_length::size(32), major_version::size(16), minor_version::size(16), param_count::size(16), rs::binary>> = binary
    {params, rss} = ExEdgeDB.Messages.Utils.decode_list(ExEdgeDB.Messages.ConnectionParam, param_count, rs)
    <<extension_count::size(16), rsss::binary>> = rss
    {extensions, rsss} = ExEdgeDB.Messages.Utils.decode_list(ExEdgeDB.Messages.ProtocolExtension, extension_count, rsss)

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

defmodule ExEdgeDB.Messages.ConnectionParam do
  @derive [ExEdgeDB.Messages.Packer]
  defstruct [:name, :value]

  def encoding(%__MODULE__{name: name, value: value}) do
    [
      name,
      value
    ]
  end

  def decode(binary) do
    {name, rs} = ExEdgeDB.Messages.Utils.decode_string(binary)
    {value, rss} = ExEdgeDB.Messages.Utils.decode_string(binary)
    {%__MODULE__{name: name, value: value}, rss}
  end
end

defmodule ExEdgeDB.Messages.ProtocolExtension do
  @derive [ExEdgeDB.Messages.Packer]
  defstruct [:name, :headers]

  def encoding(%__MODULE__{name: name, headers: headers}) do
    [
      name,
      ExEdgeDB.Messages.UInt32.new(length(headers)),
      headers
    ]
  end

  def decode(binary) do
    {name, remaining} = ExEdgeDB.Messages.Utils.decode_string(binary)
    <<length::size(32), remains::binary>> = remaining
    {headers, last} = ExEdgeDB.Messages.Utils.decode_list(ExEdgeDB.Messages.Header, length, remains)
    {%__MODULE__{name: name, headers: headers}, last}
  end
end

defmodule ExEdgeDB.Messages.Header do
  @derive [ExEdgeDB.Messages.Packer]
  defstruct [:code, :value]

  def encoding(%__MODULE__{code: code, value: value}) do
    [
      ExEdgeDB.Messages.UInt16.new(code),
      value
    ]
  end

  def decode(binary) do
    <<code::size(16), remaining::binary>> = binary
    {value, remains} = ExEdgeDB.Messages.Utils.decode_string(remaining)
    {%__MODULE__{code: code, value: value}, remains}
  end
end

