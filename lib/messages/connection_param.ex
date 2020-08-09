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
