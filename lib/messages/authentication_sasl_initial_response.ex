defmodule ExEdgeDb.Messages.AuthenticationSASLInitialResponse do
  @derive [ExEdgeDb.Messages.Packer]
  defstruct [
    :method,
    :sasl_data,
  ]

  def encoding(%__MODULE__{method: method, sasl_data: sasl_data}) do
    body = [
      method,
      sasl_data
    ]

    length = ExEdgeDb.Messages.Packer.bytesize(body) + 4

    [ExEdgeDb.Messages.UInt8.new(?p), ExEdgeDb.Messages.UInt32.new(length)] ++ body
  end

  def decode(binary) do
    <<str_length::size(32), method::binary-size(str_length), bin_length::size(32), bin::binary-size(bin_length)>> = binary

    %__MODULE__{
      method: method,
      sasl_data: bin
    }
  end
end
