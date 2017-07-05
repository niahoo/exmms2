defmodule Exmms2.IPC.Compiler do
  @ipc (Application.app_dir(:exmms2,  "priv/genipc/ipc.exs")
        |> File.read!
        |> Code.eval_string
        |> elem(0)
        )

  def ipc(),
    do: @ipc

  def create_modules() do
    @ipc[:modules]
    |> Enum.map(&create_module/1)
  end

  def create_module(defs) do
    %{functions: functions, module: module, object_id: oid} = defs
    module_name = Module.concat([Exmms2.IPC.Message, String.to_atom(module)])
    IO.puts "Creating IPC Module \"#{module_name}\""
    quote do
      defmodule unquote(module_name) do
        use unquote(__MODULE__), defs: unquote(defs)
        def object_id() do
          unquote(oid)
        end
      end
    end
  end

  defmacro __using__(using) do
    defs = Keyword.fetch!(using, :defs)
    %{functions: functions, module: module, object_id: oid} = defs
    IO.puts "Creating IPC messages functions for IPC object \"#{module}\" in module #{__CALLER__.module}"
    functions
    |> Enum.map(&create_message_function/1)
  end

  def create_message_function(info) do
    %{doc: doc, args: args, command_id: command_id, name: name,
      object_id: object_id, signal: is_signal, payload: payload_def} = info
    args_names = get_args_names(args)
    args_vars =
      args_names
      |> Enum.map(&Macro.var(&1, __MODULE__))
    args_checks =
      args
      |> Enum.map(fn
          ({name, type}) ->
            arg = Macro.var(name, __MODULE__)
            quote do
              Exmms2.IPC.validate_value!(unquote(arg), unquote(type))
            end
          ({name, :list, type}) ->
            arg = Macro.var(name, __MODULE__)
            quote do
              Exmms2.IPC.validate_list!(unquote(arg), unquote(type))
            end
          ({name, :dictionary, type}) ->
            arg = Macro.var(name, __MODULE__)
            quote do
              Exmms2.IPC.validate_dictionary!(unquote(arg), unquote(type))
            end
      end)
    payload =
      payload_def
      |> Enum.map(fn
                    ({:const, v}) -> v
                    ({:var, k}) -> Macro.var(k, __MODULE__)
                  end)
    banged =
      name
      |> Atom.to_string
      |> Kernel.<>("!")
      |> String.to_atom
    quote do
      @doc unquote(doc)
      def unquote(banged)(unquote_splicing(args_vars)) do
        unquote_splicing(args_checks)
        %Exmms2.IPC.Message{
          object_id: unquote(object_id),
          command_id: unquote(command_id),
          payload: unquote(payload),
          is_signal: unquote(is_signal),
        }
      end
      def unquote(name)(unquote_splicing(args_vars)) do
        try do
          {:ok, unquote(banged)(unquote_splicing(args_vars))}
        rescue
          e in Exmms2.IPC.ValidationException -> {:error, e.error}
          e -> {:error, e.message}
        end
      end
    end
  end

  defp get_args_names([]),
    do: []
  defp get_args_names([{k, _}|args]),
    do: [k | get_args_names(args)]
  defp get_args_names([{k, wrap, _}|args])
    when wrap === :list or wrap === :dictionary,
    do: [k | get_args_names(args)]
end
