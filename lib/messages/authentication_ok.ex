defmodule ExEdgeDb.Messages.AuthenticationOk do
  defstruct [
    :auth_status,
  ]

  def encoding(%__MODULE__{auth_status: auth_status}) do
    message_body = [
      ExEdgeDb.Messages.UInt32.new(auth_status),
    ]
    message_length = ExEdgeDb.Messages.Packer.bytesize(message_body)

    [ExEdgeDb.Messages.UInt8.new(?V), ExEdgeDb.Messages.UInt32.new(message_length + 4)] ++ message_body
  end

  def decode(binary) do
    <<auth_status::size(32)>> = binary

    %__MODULE__{
      auth_status: auth_status
    }
  end
end
