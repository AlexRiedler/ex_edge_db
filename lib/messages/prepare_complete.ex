defmodule ExEdgeDb.Messages.PrepareComplete do
  defstruct [
    :headers,
    :cardinality,
    :input_typedesc_id,
    :output_typedesc_id
  ]

  def decode(binary) do
    <<num_headers::size(16), rs::binary>> = binary
    {headers, rss} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Messages.Header, num_headers, rs)
    <<cardinality::size(8), input_typedesc_id::binary-size(16), output_typedesc_id::binary-size(16)>> = rss

    %__MODULE__{
      headers: headers,
      cardinality: cardinality,
      input_typedesc_id: input_typedesc_id,
      output_typedesc_id: output_typedesc_id
    }
  end
end
