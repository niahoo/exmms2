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
    with {:a, <<oid :: 32, sc :: 32, ck :: 32, pl :: 32, bp :: binary >>} <- {:a, bin},
         object_id = oid, status_code = sc, cookie = ck, payload_length = pl,
         bin_payload = bp,
         {:b, ^payload_length} <- {:b, byte_size(bin_payload)},
         {:c, << bin_payload :: binary-size(payload_length) >>} <- {:c, bin_payload},
         {:ok, payload} <- decode(bin_payload) do
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
    else
      {:error, err} -> {:error, err}
      other -> {:error, {:bad_reply, other}}
    end
  end

  def decode(term) do
    try do
      {:ok, decode!(term)}
    rescue
      e -> {:error, e}
    end
  end

  # an ancoded term is always 1 term : either a scalar or a coll/list/dict. The
  # unserialize/2 function accept concatenations of terms, e.g. the content of a
  # list, but decode!/1 expect the result of unserialize/1 to be a unique term.

  def decode!(term) do
    term
    |> unserialize([])
    |> assemble()
    |> case do
        [unique] -> unique
        other -> raise "terms to decode should be unique, binary : #{inspect term}"
       end
  end

  def unserialize(<< @value_type_integer, int :: 64, rest :: binary >>, acc),
    do: unserialize(rest, [int | acc])

  def unserialize(<< @value_type_list, subtype :: 32, len :: 32, rest :: binary >>, acc),
    do: unserialize(rest, [{:list, subtype, len} | acc])

  def unserialize(<< @value_type_string, len :: 32, rest :: binary >>, acc) do
    case rest do
      << str :: binary-size(len), rest_2 :: binary >> ->
        unserialize(rest_2, [str | acc])
      _other ->
        raise "unable to decode string #{inspect rest}"
    end
  end

  def unserialize("", acc),
    do: :lists.reverse(acc)
  def unserialize(bin, acc) do
    raise "unable to decode #{inspect bin}"
  end

  def assemble([{:list, _subtype, len} | pool]) do
    rest = assemble(pool)
    {members, rest_2} = Enum.split(rest, len)
    len = length(members)
    [members | rest_2]
  end
  def assemble([term | pool]),
    do: [term | assemble(pool)]
  def assemble([]),
    do: []

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




