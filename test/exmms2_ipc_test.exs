defmodule Exmms2IPCTest do
  use ExUnit.Case
  doctest Exmms2.IPC
  alias Exmms2.IPC

  test "ipc parser" do
    assert IPC.protocol_version === 24
    IPC.Message.Main.hello!(IPC.protocol_version, "xmmsremote")
    |> IO.inspect
    |> IPC.Message.encode
    |> IO.inspect
    |> IPC.Encoder.to_hex
    |> IO.puts
  end


end
