defmodule ExEdgeDb.Messages.AuthenticationSASLResponse do
  @derive [ExEdgeDb.Messages.Packer]
  defstruct [
    :sasl_data,
  ]

  def encoding(%__MODULE__{sasl_data: sasl_data}) do
    body = [
      sasl_data
    ]

    length = ExEdgeDb.Messages.Packer.bytesize(body) + 4

    [ExEdgeDb.Messages.UInt8.new(?r), ExEdgeDb.Messages.UInt32.new(length)] ++ body
  end
end
