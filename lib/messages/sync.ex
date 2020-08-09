defmodule ExEdgeDb.Messages.Sync do
  @derive [ExEdgeDb.Messages.Packer]
  defstruct [
    :headers,
    :io_format,
    :expected_cardinality,
    :statement_name,
    :command
  ]

  def encoding(%__MODULE__{}) do
    [ExEdgeDb.Messages.UInt8.new(?S), ExEdgeDb.Messages.UInt32.new(4)]
  end
end

