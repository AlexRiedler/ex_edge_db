defmodule ExEdgeDb.Messages.ServerHandshake do
  defstruct [
    :major_version,
    :minor_version,
    # ProtocolExtension
    :extensions,
  ]

  def decode(binary) do
    <<major_version::size(16), minor_version::size(16), num_extensions::size(16), rs::binary>> = binary
    {extensions, _} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Messages.ProtocolExtension, num_extensions, rs)

    %__MODULE__{
      major_version: major_version,
      minor_version: minor_version,
      extensions: extensions
    }
  end
end
