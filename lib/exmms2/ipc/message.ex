defmodule Exmms2.IPC.Message do
  defstruct [
    object_id: 0,
    command_id: 0,
    payload: [],
    is_signal: false,
    cookie: -1,
  ]

  def encode(message) do
    Todo.todo!
  end
end
