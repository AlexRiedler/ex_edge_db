defmodule ExEdgeDB do
  @moduledoc """
  Documentation for `Exedgedb`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExEdgeDB.hello()
      :world

  """
  def hello do
    :world
  end

  def test do
    {_size, msg} = ExEdgeDB.Messages.Packer.pack(
      %ExEdgeDB.Messages.ClientHandshake{
        major_version: 1,
        minor_version: 0,
        params: [],
        extensions: [
          %ExEdgeDB.Messages.ProtocolExtension{
            name: "Magic",
            headers: [
              %ExEdgeDB.Messages.Header{
                code: 1,
                value: "foo"
              },
              %ExEdgeDB.Messages.Header{
                code: 15,
                value: "bar"
              }
            ]
          }
        ]
      }
    )
    IO.inspect(ExEdgeDB.Messages.ClientHandshake.decode(msg))
  end


  def connect do
    {:ok, socket} = :gen_tcp.connect('localhost', 5656, [:binary, {:packet, 0}, {:active, false}])
    {_size, msg} = ExEdgeDB.Messages.Packer.pack(%ExEdgeDB.Messages.ClientHandshake{major_version: 1, minor_version: 0, params: [], extensions: []})
    IO.inspect("SENDING:")
    IO.inspect(msg)
    :ok = :gen_tcp.send(socket, msg)
    {:ok, msg} = receive_message(socket)
    :ok = :gen_tcp.close(socket)
    msg
  end

  def receive_message(socket) do
    {:ok, msg_type} = :gen_tcp.recv(socket, 1)
    {:ok, msg_len} = :gen_tcp.recv(socket, 4)
    {:ok, payload} = :gen_tcp.recv(socket, :binary.decode_unsigned(msg_len) - 4)
    case :binary.decode_unsigned(msg_type) do
      ?v ->
        IO.puts("Received Server Handshake")
      ?E -> 
        IO.puts("Error Occurred")
        << severity::8, error_code::32, str_size::32, remaining::binary>> = payload
        message = binary_part(remaining, 0, str_size)
        IO.puts(severity)
        IO.puts(error_code)
        IO.puts(:unicode.characters_to_list(message))
        {:ok, payload}
      _ ->
        raise("Unhandled message type")
    end
  end
end
