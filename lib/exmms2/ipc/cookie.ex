defmodule Exmms2.IPC.Cookie do
  @global __MODULE__
  require Logger

  def start_link() do
    Agent.start_link(fn() -> 0 end, name: @global)
  end

  def next() do
    Agent.get_and_update(@global, fn(cookie) ->
      new = cookie + 1
      Logger.debug("Generated new cookie : #{new}")
      {new, new}
    end)
  end
end
