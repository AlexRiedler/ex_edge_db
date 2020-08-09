defmodule ExEdgeDb.Messages.Prepare do
  @derive [ExEdgeDb.Messages.Packer]
  defstruct [
    :headers,
    :io_format,
    :expected_cardinality,
    :statement_name,
    :command
  ]

  def encoding(%__MODULE__{headers: headers, io_format: io_format, expected_cardinality: expected_cardinality, statement_name: statement_name, command: command}) do
    message_body = [
      ExEdgeDb.Messages.UInt16.new(length(headers)),
      headers,
      ExEdgeDb.Messages.UInt8.new(io_format),
      ExEdgeDb.Messages.UInt8.new(expected_cardinality),
      statement_name,
      command
    ]

    message_length = ExEdgeDb.Messages.Packer.bytesize(message_body) + 4

    [ExEdgeDb.Messages.UInt8.new(?P), ExEdgeDb.Messages.UInt32.new(message_length)] ++ message_body
  end
end
