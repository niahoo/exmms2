defmodule Exmms2.IPC.Const do
  @ipc (Application.app_dir(:exmms2,  "priv/genipc/ipc.exs")
        |> File.read!
        |> Code.eval_string
        |> elem(0)
        )
  @ipc.enums
  |> Enum.map(fn({name, kvs}) ->
      kvs
      |> Enum.map(fn({const, val}) ->
          def unquote(name)(unquote(const)) do
            unquote(val)
          end
         end)
     end)
end
