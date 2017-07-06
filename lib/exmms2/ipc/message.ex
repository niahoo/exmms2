defmodule Exmms2.IPC.Message do
  @msg __MODULE__
  defstruct [
    object_id: 0,
    command_id: 0,
    payload: [],
    is_signal: false,
    cookie: -1,
  ]

  def encode(msg = %@msg{}, suffix \\ ""),
    do: Exmms2.IPC.Codec.encode(msg) <> suffix

  def set_cookie(msg = %@msg{}, cookie) when is_integer(cookie),
    do: %@msg{msg | cookie: cookie}

end
