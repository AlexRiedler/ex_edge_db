defmodule ExEdgeDb.Types.EnumerationTypeDescriptor do
  defstruct [
    :id,
    :members
  ]

  def decode(binary) do
    <<id::binary-size(16), member_count::size(16), members_binary::binary>> = binary
    {members, _} = decode_members(members_binary, member_count)

    %__MODULE__{
      id: id,
      members: members
    }
  end

  defp decode_members(members_binary, 0) do
    {[], members_binary}
  end
  defp decode_members(members_binary, member_count) do
    {members, rest} =
      Enum.reduce(1..member_count, {[], members_binary}, fn _, {acc, binary} ->
        <<member_length::size(32), member::binary-size(member_length), remaining::binary>> = binary
        {[member | acc], remaining}
      end)
    {Enum.reverse(members), rest}
  end
end
