defmodule ExEdgeDb.Messages.ReadyForCommand do
  defstruct [
    :headers,
    :transaction_state
  ]

  def decode(binary) do
    <<num_headers::size(16), rs::binary>> = binary
    {headers, rss} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Messages.Header, num_headers, rs)
    <<transaction_state::size(8)>> = rss

    %__MODULE__{
      headers: headers,
      transaction_state: transaction_state,
    }
  end
end
