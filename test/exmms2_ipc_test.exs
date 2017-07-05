defmodule Exmms2IPCTest do
  use ExUnit.Case
  doctest Exmms2.IPC
  alias Exmms2.IPC

  test "ipc parser" do
    assert IPC.protocol_version === 24
    IPC.Main.hello!(IPC.protocol_version, "mix_test_remote")
    |> IO.inspect
    |> IPC.Message.encode
  end


end
