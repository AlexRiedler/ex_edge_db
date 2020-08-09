defmodule ExEdgeDb.Messages.Execute do
  @derive [ExEdgeDb.Messages.Packer]
  defstruct [
    :headers,
    :statement_name,
    :arguments
  ]

  def encoding(%__MODULE__{headers: headers, statement_name: statement_name, arguments: arguments}) do
    message_body = [
      ExEdgeDb.Messages.UInt16.new(length(headers)),
      headers,
      statement_name,
      arguments 
    ]

    message_length = ExEdgeDb.Messages.Packer.bytesize(message_body) + 4

    [ExEdgeDb.Messages.UInt8.new(?E), ExEdgeDb.Messages.UInt32.new(message_length)] ++ message_body
  end
end
