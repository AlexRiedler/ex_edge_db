defmodule ExEdgeDb.Messages.ServerKeyData do
  defstruct [
    :data
  ]

  def decode(binary) do
    {data, _} =
      Enum.reduce(1..32, {[], binary}, fn _, {lst,  bin} ->
        <<int::size(8), remaining::binary>> = bin
        {[int | lst], remaining}
      end)
    
    %__MODULE__{
      data: data
    }
  end
end
