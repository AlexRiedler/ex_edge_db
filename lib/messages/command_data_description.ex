defmodule ExEdgeDb.Messages.CommandDataDescription do
  defstruct [
    :headers,
    :result_cardinality,
    :input_typedesc_id,
    :input_typedesc,
    :output_typedesc_id,
    :output_typedesc
  ]

  def decode(binary) do
    <<num_headers::size(16), rs::binary>> = binary
    {headers, rss} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Messages.Header, num_headers, rs)

    <<
      result_cardinality::size(8),
      input_typedesc_id::binary-size(16),
      input_typedesc_length::size(32),
      input_typedesc::binary-size(input_typedesc_length),
      output_typedesc_id::binary-size(16),
      output_typedesc_length::size(32),
      output_typedesc::binary-size(output_typedesc_length),
    >> = rss

    %__MODULE__{
      headers: headers,
      result_cardinality: result_cardinality,
      input_typedesc_id: input_typedesc_id,
      input_typedesc: input_typedesc,
      output_typedesc_id: output_typedesc_id,
      output_typedesc: output_typedesc,
    }
  end
end
