defmodule Exmms2.IPC.Const do
  @ipc (Application.app_dir(:exmms2,  "priv/genipc/ipc.exs")
        |> File.read!
        |> Code.eval_string
        |> elem(0)
        )

  # Create the constants functions that translate an atom to a code :
  # Const.playback_status(:STOP) -> 0
  @ipc.enums
  |> Enum.map(fn({name, kvs}) ->
      kvs
      |> Enum.sort_by(fn({const, val}) -> val end)
      |> Enum.map(fn({const, val}) ->
          def unquote(name)(unquote(const)) do
            unquote(val)
          end
         end)
      # catchall
      def unquote(name)(_) do
        :error
      end
     end)

  # Create the reversed functions that have an extra '?' in the name and
  # translate a code to the corresponding atom :
  # Const.playback_status?(0) -> :STOP
  @ipc.enums
  |> Enum.map(fn({name, kvs}) ->
      qmark_name =
        name
        |> Atom.to_string
        |> Kernel.<>("?")
        |> String.to_atom
      kvs
      |> Enum.sort_by(fn({const, val}) -> val end)
      |> Enum.map(fn({const, val}) ->
          def unquote(qmark_name)(unquote(val)) do
            unquote(const)
          end
         end)
      # catchall
      def unquote(qmark_name)(_) do
        :error
      end
     end)
end
