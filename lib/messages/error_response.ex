defmodule ExEdgeDb.Messages.ErrorResponse do
  defstruct [
    :severity,
    :error_code,
    :message,
    # Header
    :attributes,
  ]

  def decode(binary) do
    <<
      severity::size(8),
      error_code::size(32),
      message_length::size(32),
      message::binary-size(message_length),
      num_attributes::size(16),
      attribute_data::binary
    >> = binary

    {attributes, _} = ExEdgeDb.Messages.Utils.decode_list(ExEdgeDb.Messages.Header, num_attributes, attribute_data)

    %__MODULE__{
      severity: severity,
      error_code: error_code,
      message: message,
      attributes: attributes
    }
  end
end
