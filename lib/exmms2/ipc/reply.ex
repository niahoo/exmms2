defmodule Exmms2.IPC.Reply do
  @msg __MODULE__
  defstruct [
    object_id: 0,
    status: 0,
    payload: [],
    cookie: -1,
  ]

  def decode!(bin) do
    {:ok, reply} = Exmms2.IPC.Codec.decode_reply(bin)
    reply
  end

  def decode(bin) do
    Exmms2.IPC.Codec.decode_reply(bin)
  end

end
