defmodule ExEdgeDb.Messages.AuthenticationSASLFinal do
  defstruct [
    :auth_status,
    :sasl_data,
  ]

  def decode(binary) do
    <<auth_status::size(32), bin_length::size(32), bin::binary-size(bin_length)>> = binary

    %__MODULE__{
      auth_status: auth_status,
      sasl_data: bin
    }
  end
end
