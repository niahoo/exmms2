defmodule Exmms2 do

  def connect(ref \\ make_ref(), tcp_uri) do
    {:ok, _pid} = Supervisor.start_child(Exmms2.Client.Supervisor, [ref, tcp_uri])
    _conn = ref
  end

  def play(conn) do

  end
end
