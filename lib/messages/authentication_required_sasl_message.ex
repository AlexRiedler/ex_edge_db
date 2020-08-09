defmodule ExEdgeDb.Messages.AuthenticationRequiredSASLMessage do
  defstruct [
    :auth_status,
    :methods,
  ]

  def decode(binary) do
    <<auth_status::size(32), num_methods::size(32), methods_bin::binary>> = binary
    {methods, _} = ExEdgeDb.Messages.Utils.decode_string_list(num_methods, methods_bin)

    %__MODULE__{
      auth_status: auth_status,
      methods: methods
    }
  end
end
