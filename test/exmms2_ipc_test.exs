defmodule Exmms2IPCTest do
  use ExUnit.Case
  doctest Exmms2.IPC
  alias Exmms2.IPC
  alias Exmms2.IPC.Const

  @test_url System.get_env("XMMS_PATH")
  @test_url "tcp://192.168.1.100:5555"

  test "ipc parser" do
    assert IPC.protocol_version === 24
    msg =
      IPC.Message.Main.hello!(IPC.protocol_version, "xmmsremote")
      |> IPC.Message.encode
    assert << 1 :: 32, 32 :: 32, _ :: 32, _ :: binary >> = msg
  end

  test "ipc enums" do
    assert IPC.Const.ipc_command_special(:REPLY) === 0
    assert IPC.Const.ipc_command_special(:ERROR) === 1
    assert IPC.Const.collection_type(:LAST) === IPC.Const.collection_type(:IDLIST)
    assert IPC.Const.ipc_command_signal(:SIGNAL) === 32
    assert IPC.Const.ipc_command_signal(:BROADCAST) === 33
  end

  test "ipc connection" do
    conn = Exmms2.connect(@test_url)
    assert :pong = Exmms2.Client.ping(conn)
    {:ok, status} =
      Exmms2.Client.Playback.status(conn)
    assert status in [
      Const.playback_status(:PLAY),
      Const.playback_status(:PAUSE),
      Const.playback_status(:STOP),
    ]
    assert Const.playback_status?(status) in [
      :PLAY,
      :PAUSE,
      :STOP,
    ]
  end

  test "ipc codec" do
    encode_decode(1)
    encode_decode("Hello")
    encode_decode([[1, 2, 3, 4, "Hi"], "Bye"])
  end

  def encode_decode(term) do
    comp =
      term
      |> Exmms2.IPC.Codec.encode
      # |> IO.inspect
      |> Exmms2.IPC.Codec.decode!
      # |> IO.inspect
    assert ^term = comp
  end
end
