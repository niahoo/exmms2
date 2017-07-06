defmodule Exmms2.IPC.Codec.Helper do
  def int32(int) when is_integer(int) do
    <<int :: 32>>
  end

  def int64(int) when is_integer(int) do
    <<int :: 64>>
  end
end

defmodule Exmms2.IPC.Codec do
  alias Exmms2.IPC.Message
  alias Exmms2.IPC.Reply
  alias Exmms2.IPC.Const
  import Exmms2.IPC.Codec.Helper

  @value_type_none       int32(0x00)
  @value_type_error      int32(0x01)
  @value_type_integer    int32(0x02)
  @value_type_string     int32(0x03)
  @value_type_collection int32(0x04)
  @value_type_binary     int32(0x05)
  @value_type_list       int32(0x06)
  @value_type_dictionary int32(0x07)

  def encode(msg = %Message{}) do
    object_id = int32(msg.object_id)
    command_id = int32(msg.command_id)
    cookie = int32(msg.cookie)
    payload = encode(msg.payload)
    payload_length =
      payload
      |> byte_size()
      |> int32()
    join_binaries([object_id, command_id, cookie, payload_length, payload])
  end

  def encode(term) do
    term
    |> serialize()
    |> :lists.flatten
    |> join_binaries
  end

  def serialize(list) when is_list(list),
    do: serialize_list(list, @value_type_none)

  def serialize(n) when is_integer(n),
    do: [@value_type_integer, int64(n)]

  def serialize(str) when is_binary(str) do
    len = byte_size(str)
    [@value_type_string, int32(len), str]
  end

  def serialize_list(list, subtype) when is_list(list) do
    len = length(list)
    items =
      for item <- list do
        serialize(item)
      end
    [@value_type_list, subtype, int32(len) | items]
  end

  defp join_binaries(bins) do
    Enum.join(bins)
  end

  def decode_reply(bin) when is_binary(bin) do
    IO.inspect bin
    case bin do
      <<object_id :: 32, status_code :: 32, cookie :: 32, payload_length :: 32, bin_payload :: binary >>
      when byte_size(bin_payload) === payload_length ->
        payload = decode_payload(bin_payload, payload_length)
        status =
          cond do
            status_code == Const.ipc_command_special(:REPLY) -> :ok
            status_code == Const.ipc_command_special(:ERROR) -> :error
            true -> :unknown
          end
        reply = %Reply{
          object_id: object_id,
          status: status,
          cookie: cookie,
          payload: payload
        }
        {:ok, reply}
      _otherwise ->
        {:error, {:bad_reply, bin}}
    end
  end

  def decode_payload(bin, len) do
    "This iz my payload"
  end

  def to_hex(bin) when is_binary(bin) do
    hex =
      bin
      |> Base.encode16
      |> String.to_charlist
      |> format_hex(0)
      |> to_string
  end

  def format_hex([char|charlist], 0),
    do: [char | format_hex(charlist, 1)]
  def format_hex([char|charlist], index) when rem(index, 8 * 4) === 0,
    do: ["\n", char | format_hex(charlist, index + 1)]
  def format_hex([char|charlist], index) when rem(index, 8) === 0,
    do: ["  ", char | format_hex(charlist, index + 1)]
  def format_hex([char|charlist], index) when rem(index, 2) === 0,
    do: [" ", char | format_hex(charlist, index + 1)]
  def format_hex([char|charlist], index),
    do: [char | format_hex(charlist, index + 1)]
  def format_hex([], i),
    do: []
end




