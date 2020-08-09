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
end

