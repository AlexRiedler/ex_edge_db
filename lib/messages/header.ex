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
