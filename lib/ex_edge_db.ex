defmodule ExEdgeDb do
  @moduledoc """
  Documentation for `ExEdgeDb`.
  """

  @doc """
  Connect to Database

  ## Examples

      iex> ExEdgeDb.connect()
      :world

  """
  def connect do
    {:ok, socket} = :gen_tcp.connect('localhost', 5656, [:binary, {:packet, 0}, {:active, false}])
    {_size, msg} = ExEdgeDb.Messages.Packer.pack(client_handshake_msg())
    :ok = :gen_tcp.send(socket, msg)
    Stream.unfold(receive_message(socket), fn {status, msg} ->
      IO.inspect(msg)
      case status do
        :ok ->
          {_size, packed_msg} = ExEdgeDb.Messages.Packer.pack(msg)
          :gen_tcp.send(socket, packed_msg)
          {msg, receive_message(socket)}
        _ ->
          nil
      end
    end)
    |> Enum.to_list()
    :ok = :gen_tcp.close(socket)
  end

  def client_handshake_msg do
    %ExEdgeDb.Messages.ClientHandshake{
      major_version: 0,
      minor_version: 8,
      params: [
        %ExEdgeDb.Messages.ConnectionParam{
          name: "user",
          value: "ariedler"
        },
        %ExEdgeDb.Messages.ConnectionParam{
          name: "database",
          value: "send_development"
        },
      ],
      extensions: []
    }
  end

  def receive_message(socket) do
    {:ok, msg_type} = :gen_tcp.recv(socket, 1)
    IO.puts("RECEIVED: #{msg_type}")
    {:ok, msg_len} = :gen_tcp.recv(socket, 4)
    {:ok, payload} = :gen_tcp.recv(socket, :binary.decode_unsigned(msg_len) - 4)

    username = "ariedler"
    password = "password"
    client_nonce = "QG1pafRtAWLf9PASeiJK8HAN" # TODO: Base.encode64(:crypto.strong_rand_bytes(18))
    case :binary.decode_unsigned(msg_type) do
      ?v ->
        ExEdgeDb.Messages.ServerHandshake.decode(payload)
        # TODO: verify major / minor version is supported
      ?R ->
        <<auth_status::size(32), _::binary>> = payload
        case auth_status do
          0xa ->
            # TODO: verify method is allowed
            _sasl_required = ExEdgeDb.Messages.AuthenticationRequiredSASLMessage.decode(payload)

            method = "SCRAM-SHA-256"
            sasl_data = "n,,n=#{username},r=#{client_nonce}"

            {:ok, %ExEdgeDb.Messages.AuthenticationSASLInitialResponse{method: method, sasl_data: sasl_data}} 
          0xb ->
            %{sasl_data: server_sasl_data} = ExEdgeDb.Messages.AuthenticationSASLContinue.decode(payload)

            IO.inspect(server_sasl_data)

            data =
              server_sasl_data
              |> String.split(",")
              |> Enum.map(fn x -> String.split(x, "=", parts: 2) end)
              |> Map.new(fn [x,y] -> {x, y} end)

            i = Map.get(data, "i") |> String.to_integer
            r = Map.get(data, "r")
            {:ok, salt} = Map.get(data, "s") |> Base.decode64

            client_final_without_proof = "c=biws,r=#{r}"
            client_first_without_header = "n=#{username},r=#{client_nonce}"

            auth_message = [client_first_without_header, server_sasl_data, client_final_without_proof] |> Enum.join(",")
            salted_password = Plug.Crypto.KeyGenerator.generate(password, salt, iterations: i)

            client_key = :crypto.hmac(:sha256, salted_password, "Client Key")
            stored_key = :crypto.hash(:sha256, client_key)
            client_signature = :crypto.hmac(:sha256, stored_key, auth_message)
            client_proof = :crypto.exor(client_key, client_signature)

            server_key = :crypto.hmac(:sha256, salted_password, "Server Key")
            server_proof = :crypto.hmac(:sha256, server_key, auth_message)

            IO.puts(server_proof |> Base.encode64)

            sasl_data = "c=biws,r=#{r},p=#{client_proof |> Base.encode64}"

            IO.inspect(sasl_data)

            {:ok, %ExEdgeDb.Messages.AuthenticationSASLResponse{sasl_data: sasl_data}}
          0xc ->
            # TODO: verify server_proof
            sasl_final = ExEdgeDb.Messages.AuthenticationSASLFinal.decode(payload)
            receive_message(socket)
          0x0 ->
            auth_ok = ExEdgeDb.Messages.AuthenticationOk.decode(payload)
            receive_message(socket)
        end
      ?p ->
        ExEdgeDb.Messages.AuthenticationSASLInitialResponse.decode(payload)
      ?E -> 
        ExEdgeDb.Messages.ErrorResponse.decode(payload)
      ?K ->
        server_key_data = ExEdgeDb.Messages.ServerKeyData.decode(payload)
        IO.inspect(server_key_data)
        receive_message(socket)
      ?Z ->
        ready_for_command = ExEdgeDb.Messages.ReadyForCommand.decode(payload)
        IO.inspect(ready_for_command)

        prepare_message = %ExEdgeDb.Messages.Prepare{headers: [], io_format: 0x6a, expected_cardinality: 0x6d, statement_name: <<>>, command: "Select Person { first_name, last_name } FILTER Person.last_name = 'Ana'"}
        {_, prepare_payload} = ExEdgeDb.Messages.Packer.pack(prepare_message)
        IO.inspect(prepare_message)
        IO.inspect(prepare_payload)

        :ok = :gen_tcp.send(socket, prepare_payload)

        # have to sync, otherwise nothing happens
        {_, sync_payload} = ExEdgeDb.Messages.Packer.pack(%ExEdgeDb.Messages.Sync{})
        :ok = :gen_tcp.send(socket, sync_payload)

        receive_message(socket)
      ?1 ->
        prepare_complete = ExEdgeDb.Messages.PrepareComplete.decode(payload)
        IO.inspect(prepare_complete)

        execute_message = %ExEdgeDb.Messages.Execute{headers: [], statement_name: <<>>, arguments: <<>>}
        {_, execute_payload} = ExEdgeDb.Messages.Packer.pack(execute_message)
        IO.inspect(execute_payload)
        :ok = :gen_tcp.send(socket, execute_payload)

        # have to sync, otherwise nothing happens
        #{_, sync_payload} = ExEdgeDb.Messages.Packer.pack(%ExEdgeDb.Messages.Sync{})
        #:ok = :gen_tcp.send(socket, sync_payload)

        {:ok, msg_type} = :gen_tcp.recv(socket, 1)
        IO.puts("RECEIVED: #{msg_type}")
        {:ok, msg_len} = :gen_tcp.recv(socket, 4)
        {:ok, payload} = :gen_tcp.recv(socket, :binary.decode_unsigned(msg_len) - 4)
        ready_for_command = ExEdgeDb.Messages.ReadyForCommand.decode(payload)
        IO.inspect(ready_for_command)

        {:ok, msg_type} = :gen_tcp.recv(socket, 1)
        IO.puts("RECEIVED: #{msg_type}")
        {:ok, msg_len} = :gen_tcp.recv(socket, 4)
        {:ok, payload} = :gen_tcp.recv(socket, :binary.decode_unsigned(msg_len) - 4)
        error_response = ExEdgeDb.Messages.ErrorResponse.decode(payload)
        IO.inspect(error_response)

        # hangs waiting on a message
        {:ok, msg_type} = :gen_tcp.recv(socket, 1)
        IO.puts("RECEIVED: #{msg_type}")
        {:ok, msg_len} = :gen_tcp.recv(socket, 4)
        {:ok, payload} = :gen_tcp.recv(socket, :binary.decode_unsigned(msg_len) - 4)
        IO.inspect(payload)
        
        nil
      _ ->
        raise("Unhandled message type: '#{msg_type}'")
    end
  end
end
