defmodule ExEdgeDb.Messages.Terminate do
  @derive [ExEdgeDb.Messages.Packer]
  defstruct []

  def encoding(%__MODULE__{}) do
    [
      ExEdgeDb.Messages.UInt8.new(?X),
      ExEdgeDb.Messages.UInt32.new(4)
    ]
  end
end
