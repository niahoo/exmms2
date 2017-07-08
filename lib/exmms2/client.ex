defmodule Exmms2.Client do
  require Logger
  use GenServer
  alias Exmms2.IPC
  alias Exmms2.IPC.Codec
  alias Exmms2.IPC.Cookie
  alias Exmms2.IPC.Message
  alias Exmms2.IPC.Reply
  alias Exmms2.IPC.Const
  alias Socket.Stream, as: SStream

  def via(ref) do
    {:via, Registry, {Exmms2.Client.Registry, ref}}
  end

  def start_link(ref, tcp_uri) do
    GenServer.start_link(__MODULE__, [ref, tcp_uri], name: via(ref))
  end

  def ping(ref) do
    GenServer.call(via(ref), :ping)
  end

  def call(ref, msg = %Message{}, timeout \\ :infinity) do
    cookie = Cookie.next()
    msg = Message.set_cookie(msg, cookie)
    Logger.debug("Sending IPC message #{inspect msg}")
    binary_msg = Message.encode(msg)
    with {:ok, binary_reply} <- GenServer.call(via(ref), {:binary_call, binary_msg}, timeout),
         {:ok, reply} <- Reply.decode(binary_reply)
      do
        Logger.debug("Received IPC reply #{inspect reply}")
        case reply.status do
          :ok -> {:ok, reply}
          :error -> {:error, reply}
        end
    end
  end

  # -- Server side ------------------------------------------------------------

  defmodule S do
    defstruct [:ref, :sock, :client_id]
  end

  def init([ref, tcp_uri]) do
    {:ok, sock} = Socket.connect(tcp_uri)
    Logger.debug("Exmms2 #{inspect ref} connecting to #{tcp_uri}")
    {:ok, client_id} = connect_hello(sock)
    Logger.debug("#{inspect ref} Connection established, client id: #{client_id}")
    state = %S{ref: ref, sock: sock, client_id: client_id}
    {:ok, state}
  end

  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  def handle_call({:binary_call, msg}, _from, state) do
    sock = state.sock
    log_message(msg)
    :ok = SStream.send(sock, msg)
    {:reply, recv(sock), state}
  end

  @default_timeout 1_000

  defp recv(sock) do
    case SStream.recv(sock, timeout: @default_timeout) do
      {:error, :timeout} ->
        Logger.warn """
          IPC receive seems slow, #{@default_timeout / 1000} seconds elapsed
        """
        recv(sock) # loop because we want the answer
      {:ok, reply} ->
        log_reply(reply)
        {:ok, reply}
      {:error, err} ->
        {:error, err}
    end
  end

  defp log_message(bin) when is_binary(bin) do
    Logger.debug("Outgoing IPC message\n#{Codec.to_hex bin}")
    bin
  end
  defp log_reply(bin = <<_ :: 32, 1 :: 32, _ :: binary>>) do
    case Reply.decode(bin) do
      {:ok, %Reply{payload: {:error, err}}} ->
        Logger.error("Incoming IPC reply ERROR\n#{err}")
      _otherwise ->
        Logger.error("Incoming IPC reply ERROR\n#{Codec.to_hex bin}")
    end
    bin
  end
  defp log_reply(bin) when is_binary(bin) do
    Logger.debug("Incoming IPC reply\n#{Codec.to_hex bin}")
    bin
  end

  defp connect_hello(sock) do
    cookie = Cookie.next()
    msg =
      Message.Main.hello!(IPC.protocol_version, "exmms2_conn")
      |> Message.set_cookie(cookie)
      |> Message.encode()
      |> log_message
    SStream.send!(sock, msg)
    SStream.recv!(sock)
    |> log_reply
    |> Reply.decode!
    |> case do
        %Reply{status: :ok, payload: client_id, cookie: ^cookie}
        when is_integer(client_id) ->
          {:ok, client_id}
        other ->
          {:error, {:bad_hello_reply, other}}
       end
  end

end



