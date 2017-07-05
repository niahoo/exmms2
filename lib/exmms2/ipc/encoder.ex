defmodule Exmms2.IPC.Encoder.Helper do
  def int32(int) when is_integer(int) do
    <<int :: 32>>
  end

  def int64(int) when is_integer(int) do
    <<int :: 64>>
  end
end

defmodule Exmms2.IPC.Encoder do
  alias Exmms2.IPC.Message, as: Msg
  import Exmms2.IPC.Encoder.Helper

  @value_type_none       int32(0x00)
  @value_type_error      int32(0x01)
  @value_type_integer    int32(0x02)
  @value_type_string     int32(0x03)
  @value_type_collection int32(0x04)
  @value_type_binary     int32(0x05)
  @value_type_list       int32(0x06)
  @value_type_dictionary int32(0x07)

  def encode(msg = %Msg{}) do
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
    |> build()
    |> :lists.flatten
    |> join_binaries
  end

  def build(list) when is_list(list),
    do: build_list(list, @value_type_none)

  def build(n) when is_integer(n),
    do: [@value_type_integer, int64(n)]

  def build(str) when is_binary(str) do
    len = byte_size(str)
    [@value_type_string, int32(len), str]
  end

  def build_list(list, subtype) when is_list(list) do
    len = length(list)
    items =
      for item <- list do
        build(item)
      end
    [@value_type_list, subtype, int32(len)|items]
  end

  defp join_binaries(bins) do
    Enum.join(bins)
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




