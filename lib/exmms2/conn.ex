defmodule Exmms2.Conn do
  use GenServer
  alias Exmms2.IPC
  alias Exmms2.IPC.Message
  alias Exmms2.IPC.Reply
  alias Exmms2.IPC.Const
  alias Socket.Stream, as: SStream

  def via(ref) do
    {:via, Registry, {Exmms2.Conn.Registry, ref}}
  end

  def start_link(ref, tcp_uri) do
    GenServer.start_link(__MODULE__, [ref, tcp_uri], name: via(ref))
  end

  def ping(ref) do
    GenServer.call(via(ref), :ping)
  end

  # -- Server side ------------------------------------------------------------

  defmodule S do
    defstruct [:ref, :sock, :client_id, :cookie]
  end

  def init([ref, tcp_uri]) do
    {:ok, sock} = Socket.connect(tcp_uri)
    cookie = 1
    {:ok, client_id} = connect_hello(sock, cookie)
    state = %S{ref: ref, sock: sock, client_id: client_id, cookie: 2}
    {:ok, state}
  end

  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  defp connect_hello(sock, cookie) do
    msg =
      Message.Main.hello!(IPC.protocol_version, "exmms2_conn")
      |> Message.set_cookie(cookie)
      |> Message.encode
      |> IO.inspect
    SStream.send!(sock, msg <> "\n")
    SStream.recv!(sock)
    |> Reply.decode!
    |> IO.inspect
    {:ok, 1}
  end

end



