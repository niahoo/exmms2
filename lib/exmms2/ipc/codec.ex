defmodule Exmms2.IPC.Codec.Helper do
  def int32(int) when is_integer(int) do
    <<int :: 32>>
  end
end

defmodule Exmms2.IPC.Codec do
  alias Exmms2.IPC.Message
  alias Exmms2.IPC.Reply
  alias Exmms2.IPC.Const
  import Exmms2.IPC.Codec.Helper

  @send_empty_payload true

  if true do
    @int_size 64
    @str_null_byte false
    @list_subtypes true
  else
    @int_size 32
    @str_null_byte true
    @list_subtypes false
  end

  @value_type_none       int32(0x00)
  @value_type_error      int32(0x01)
  @value_type_integer    int32(0x02)
  @value_type_string     int32(0x03)
  @value_type_collection int32(0x04)
  @value_type_binary     int32(0x05)
  @value_type_list       int32(0x06)
  @value_type_dictionary int32(0x07)


  def integer(int) when is_integer(int) do
    <<int :: @int_size>>
  end

  def encode(msg = %Message{}) do
    object_id = int32(msg.object_id)
    command_id = int32(msg.command_id)
    cookie = int32(msg.cookie)
    {bin_payload, payload_length} =
      case msg.payload do
        [] when not @send_empty_payload -> {"", int32(0)}
        list ->
          payload =
            encode(list)
            # list
            # |> Enum.map(&encode/1)
            # |> join_binaries
          plen =
            payload
            |> byte_size()
            |> int32()
          {payload, plen}
      end
    join_binaries([object_id, command_id, cookie, payload_length, bin_payload])
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
    do: [@value_type_integer, integer(n)]

  def serialize(str) when is_binary(str) do
    str =
      unquote(
        if @str_null_byte do
          quote do: << var!(str) :: binary, 0 >>
        else
          quote do: << var!(str) :: binary>>
        end
      )
    len = byte_size(str)
    [@value_type_string, int32(len), str]
  end

  def serialize_list(list, subtype) when is_list(list) do
    len = length(list)
    items = for item <- list, do: serialize(item)
    unquote(
      if @list_subtypes do
        quote do: [@value_type_list, var!(subtype)]
      else
        quote do: [@value_type_list]
      end
    ) ++ [int32(len) | items]
  end

  defp join_binaries(bins) do
    Enum.join(bins)
  end

@reply_ok_code Const.code(:ipc_command_special, :REPLY)
@reply_error_code Const.code(:ipc_command_special, :ERROR)

  def decode_reply(bin) when is_binary(bin) do
    with {:a, <<oid :: 32, sc :: 32, ck :: 32, pl :: 32, bp :: binary >>} <- {:a, bin},
         object_id = oid, status_code = sc, cookie = ck, payload_length = pl,
         bin_payload = bp,
         {:b, ^payload_length} <- {:b, byte_size(bin_payload)},
         {:c, << bin_payload :: binary-size(payload_length) >>} <- {:c, bin_payload},
         {:ok, payload} <- decode(bin_payload) do
          status =
            case status_code do
              @reply_ok_code -> :ok
              @reply_error_code -> :error
              _ -> :unknown
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

  def unserialize(<< @value_type_integer, int :: @int_size, rest :: binary >>, acc),
    do: unserialize(rest, [int | acc])

  def unserialize(<< @value_type_list, subtype :: 32, len :: 32, rest :: binary >>, acc),
    do: unserialize(rest, [{:list, subtype, len} | acc])

  def unserialize(<< @value_type_string, len :: 32, rest :: binary >>, acc) do
    short = len - 1
    case rest do
      << str :: binary-size(short), 0, rest_2 :: binary >> ->
        unserialize(rest_2, [str | acc])
      << str :: binary-size(len), rest_2 :: binary >> ->
        unserialize(rest_2, [str | acc])
      _other ->
        raise "unable to decode string #{inspect rest}"
    end
  end

  def unserialize(<< @value_type_error, len :: 32, rest :: binary >>, acc) do
    len = len - 1
    case rest do
      << err :: binary-size(len), 0, rest_2 :: binary >> ->
        unserialize(rest_2, [{:error, err} | acc])
      _other ->
        raise "unable to decode error #{inspect rest}"
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




