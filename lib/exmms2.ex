defmodule Exmms2 do

  def connect(ref \\ make_ref(), tcp_uri) do
    {:ok, _pid} = Supervisor.start_child(Exmms2.Conn.Supervisor, [ref, tcp_uri])
    ref
  end

end
