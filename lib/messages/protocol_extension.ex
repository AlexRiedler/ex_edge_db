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
