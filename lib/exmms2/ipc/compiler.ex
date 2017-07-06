defmodule Exmms2.IPC.Compiler do
  @ipc (Application.app_dir(:exmms2,  "priv/genipc/ipc.exs")
        |> File.read!
        |> Code.eval_string
        |> elem(0)
        )

  def ipc(),
    do: @ipc

  def create_message_modules() do
    @ipc[:modules]
    |> Enum.map(&create_message_module/1)
  end

  def create_message_module(defs) do
    %{functions: functions, module: module, object_id: oid} = defs
    module_name = Module.concat([Exmms2.IPC.Message, String.to_atom(module)])
    IO.puts "Creating IPC Message Module \"#{module_name}\""
    quote do
      defmodule unquote(module_name) do
        require unquote(__MODULE__)
        unquote(__MODULE__).create_message_functions(unquote(defs))

        def object_id() do
          unquote(oid)
        end
      end
    end
  end

  defmacro create_message_functions(defs) do
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

  def create_client_modules() do
    @ipc[:modules]
    |> Enum.map(&create_client_module/1)
  end

  def create_client_module(defs) do
    %{functions: functions, module: module} = defs
    module_name = Module.concat([Exmms2.Client, String.to_atom(module)])
    IO.puts "Creating Client Module \"#{module_name}\""
    quote do
      defmodule unquote(module_name) do
        require unquote(__MODULE__)
        unquote(__MODULE__).create_client_functions(unquote(defs))
      end
    end
  end

  defmacro create_client_functions(defs) do
    %{functions: functions, module: module, object_id: oid} = defs
    IO.puts "Creating IPC client functions for IPC object \"#{module}\" in module #{__CALLER__.module}"

    functions
    |> Enum.filter(&function_in_api(module, &1.name))
    |> Enum.map(&create_client_function/1)
  end

  def create_client_function(info) do
    %{doc: doc, args: args, command_id: command_id, name: name,
      object_id: object_id, signal: is_signal, module: module} = info
    args_names = get_args_names(args)
    args_vars =
      args_names
      |> Enum.map(&Macro.var(&1, __MODULE__))
    # banged =
    #   name
    #   |> Atom.to_string
    #   |> Kernel.<>("!")
    #   |> String.to_atom
    message_module = Module.concat([Exmms2.IPC.Message, String.to_atom(module)])
    quote do
      @doc unquote(doc)
      def unquote(name)(conn, unquote_splicing(args_vars)) do
        # Call the same function on the message module to get the according
        # message for this function.
        # Client.Main.hello(arg1, arg2) sends IPC.Message.Main.hello(arg1, arg2)
        with {:ok, message} <- unquote(message_module).unquote(name)(unquote_splicing(args_vars)),
             {:ok, reply = %Exmms2.IPC.Reply{status: :ok, payload: p}} <- Exmms2.Client.call(conn, message)
          do
            {:ok, p}
          else
             {:error, reply = %Exmms2.IPC.Reply{status: :error, payload: p}} ->
              {:error, err} = p
              p
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

  # filter out some functions that must not be used to send messages directly to
  # xmms2. Messages are rather used internally in the client.
  def function_in_api("Main", :hello), do: false
  def function_in_api("Main", :quit), do: false
  def function_in_api("Config", :set_value), do: false
  def function_in_api("Config", :register_value), do: false
  def function_in_api("Config", :broadcast_value_changed), do: false
  def function_in_api("Courier", _), do: false
  def function_in_api("IpcManager", _), do: false
  def function_in_api("Main", :broadcast_quit), do: false
  def function_in_api(_, _), do: true # all others functions are accepted

  # def function_in_api("Main", :list_plugins), do: false
  # def function_in_api("Main", :stats), do: false
  # def function_in_api("Playlist", :replace), do: false
  # def function_in_api("Playlist", :set_next), do: false
  # def function_in_api("Playlist", :set_next_rel), do: false
  # def function_in_api("Playlist", :add_url), do: false
  # def function_in_api("Playlist", :add_collection), do: false
  # def function_in_api("Playlist", :remove_entry), do: false
  # def function_in_api("Playlist", :move_entry), do: false
  # def function_in_api("Playlist", :list_entries), do: false
  # def function_in_api("Playlist", :current_pos), do: false
  # def function_in_api("Playlist", :current_active), do: false
  # def function_in_api("Playlist", :insert_url), do: false
  # def function_in_api("Playlist", :insert_collection), do: false
  # def function_in_api("Playlist", :load), do: false
  # def function_in_api("Playlist", :radd), do: false
  # def function_in_api("Playlist", :rinsert), do: false
  # def function_in_api("Playlist", :broadcast_changed), do: false
  # def function_in_api("Playlist", :broadcast_current_pos), do: false
  # def function_in_api("Playlist", :broadcast_loaded), do: false
  # def function_in_api("Config", :get_value), do: false
  # def function_in_api("Config", :list_values), do: false
  # def function_in_api("Playback", :start), do: false
  # def function_in_api("Playback", :stop), do: false
  # def function_in_api("Playback", :pause), do: false
  # def function_in_api("Playback", :tickle), do: false
  # def function_in_api("Playback", :playtime), do: false
  # def function_in_api("Playback", :seek_ms), do: false
  # def function_in_api("Playback", :seek_samples), do: false
  # def function_in_api("Playback", :status), do: false
  # def function_in_api("Playback", :current_id), do: false
  # def function_in_api("Playback", :volume_set), do: false
  # def function_in_api("Playback", :volume_get), do: false
  # def function_in_api("Playback", :broadcast_status), do: false
  # def function_in_api("Playback", :broadcast_volume_changed), do: false
  # def function_in_api("Playback", :broadcast_current_id), do: false
  # def function_in_api("Medialib", :get_info), do: false
  # def function_in_api("Medialib", :import_path), do: false
  # def function_in_api("Medialib", :rehash), do: false
  # def function_in_api("Medialib", :get_id), do: false
  # def function_in_api("Medialib", :remove_entry), do: false
  # def function_in_api("Medialib", :set_property_string), do: false
  # def function_in_api("Medialib", :set_property_int), do: false
  # def function_in_api("Medialib", :remove_property), do: false
  # def function_in_api("Medialib", :move_entry), do: false
  # def function_in_api("Medialib", :add_entry), do: false
  # def function_in_api("Medialib", :broadcast_entry_added), do: false
  # def function_in_api("Medialib", :broadcast_entry_changed), do: false
  # def function_in_api("Medialib", :broadcast_entry_removed), do: false
  # def function_in_api("Collection", :get), do: false
  # def function_in_api("Collection", :list), do: false
  # def function_in_api("Collection", :save), do: false
  # def function_in_api("Collection", :remove), do: false
  # def function_in_api("Collection", :find), do: false
  # def function_in_api("Collection", :rename), do: false
  # def function_in_api("Collection", :query), do: false
  # def function_in_api("Collection", :query_infos), do: false
  # def function_in_api("Collection", :idlist_from_playlist), do: false
  # def function_in_api("Collection", :broadcast_changed), do: false
  # def function_in_api("Visualization", :query_version), do: false
  # def function_in_api("Visualization", :register), do: false
  # def function_in_api("Visualization", :init_shm), do: false
  # def function_in_api("Visualization", :init_udp), do: false
  # def function_in_api("Visualization", :set_property), do: false
  # def function_in_api("Visualization", :set_properties), do: false
  # def function_in_api("Visualization", :shutdown), do: false
  # def function_in_api("MediainfoReader", :broadcast_status), do: false
  # def function_in_api("Xform", :browse), do: false
  # def function_in_api("Bindata", :retrieve), do: false
  # def function_in_api("Bindata", :add), do: false
  # def function_in_api("Bindata", :remove), do: false
  # def function_in_api("Bindata", :list), do: false
  # def function_in_api("CollSync", :sync), do: false
  # def function_in_api("Courier", :send_message), do: false
  # def function_in_api("Courier", :reply), do: false
  # def function_in_api("Courier", :get_connected_clients), do: false
  # def function_in_api("Courier", :ready), do: false
  # def function_in_api("Courier", :get_ready_clients), do: false
  # def function_in_api("Courier", :broadcast_message), do: false

end

IO.puts "Generating IPC modules from ipc.xml"

Exmms2.IPC.Compiler.create_message_modules()
|> Code.eval_quoted
Exmms2.IPC.Compiler.create_client_modules()
|> Code.eval_quoted
