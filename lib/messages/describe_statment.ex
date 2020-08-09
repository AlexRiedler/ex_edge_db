defmodule ExEdgeDb.Messages.DescribeStatement do
  defstruct [
    :headers,
    :aspect,
    :statement_name
  ]

  def encoding(%__MODULE__{headers: headers, aspect: aspect, statement_name: statement_name}) do
    message_body = [
      ExEdgeDb.Messages.UInt16.new(length(headers)),
      headers,
      ExEdgeDb.Messages.UInt8.new(aspect),
      statement_name
    ]

    message_length = ExEdgeDb.Messages.Packer.bytesize(message_body) + 4

    [ExEdgeDb.Messages.UInt8.new(?D), ExEdgeDb.Messages.UInt32.new(message_length)] ++ message_body
  end

  def decode(binary) do
    <<num_headers::size(16), rs::binary>> = binary
    {headers, rss} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Messages.Header, num_headers, rs)
    <<aspect::size(8), statement_name_length::size(32), statement_name::binary-size(statement_name_length)>> = rss

    %__MODULE__{
      headers: headers,
      aspect: aspect,
      statement_name: statement_name
    }
  end
end
