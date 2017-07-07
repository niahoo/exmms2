defmodule Exmms2.IPC.Const do

  # Deals with IPC enums. "code" stands for IPC integer values and "key" stands
  # for enum names represented as atoms like :PLAY, :PAUSE, etc.

  require Logger
  @ipc (Application.app_dir(:exmms2,  "priv/genipc/ipc.exs")
        |> File.read!
        |> Code.eval_string
        |> elem(0)
        )
  @doc """
    Returns the key for an enum value
    key(:playback_status, 0) -> :STOP
  """
  def key(enum_name, ipc_code)

  @ipc.enums
  |> Enum.map(fn({enum_name, kvs}) ->
      kvs
      |> Enum.sort_by(fn({const, val}) -> val end)
      |> Enum.map(fn({const, val}) ->
          def key(unquote(enum_name), unquote(val)),
            do: unquote(const)
         end)
     end)
  # catchall
  def key(enum_name, _other) do
    Logger.error("Key not found for :#{enum_name} / #{inspect _other}.")
    :error
  end
  @doc """
    Returns the code for an enum key
    name(:playback_status, :STOP) -> 0
  """
  def code(enum_name, key)

  # Create the reversed functions that have an extra '?' in the name and
  # translate a code to the corresponding atom :
  # Const.playback_status?(0) -> :STOP
  @ipc.enums
  |> Enum.map(fn({enum_name, kvs}) ->
      kvs
      |> Enum.sort_by(fn({const, val}) -> val end)
      |> Enum.map(fn({const, val}) ->
          def code(unquote(enum_name), unquote(const)),
            do: unquote(val)
         end)
     end)

  # catchall
  def code(enum_name, _other) do
    Logger.error("Code not found for :#{enum_name} / #{inspect _other}.")
    :error
  end
end
