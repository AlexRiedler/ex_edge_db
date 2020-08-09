defmodule ExEdgeDb.Messages.ClientHandshake do
  @derive [ExEdgeDb.Messages.Packer]
  defstruct [
    :major_version,
    :minor_version,
    # ConnectionParam
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

    message_length = ExEdgeDb.Messages.Packer.bytesize(message_body) + 4

    [ExEdgeDb.Messages.UInt8.new(?V), ExEdgeDb.Messages.UInt32.new(message_length)] ++ message_body
  end

  def decode(binary) do
    <<major_version::size(16), minor_version::size(16), param_count::size(16), rs::binary>> = binary
    {params, rss} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Messages.ConnectionParam, param_count, rs)
    <<extension_count::size(16), rsss::binary>> = rss
    {extensions, _} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Messages.ProtocolExtension, extension_count, rsss)

    %__MODULE__{
      major_version: major_version,
      minor_version: minor_version,
      params: params,
      extensions: extensions
    }
  end
end
