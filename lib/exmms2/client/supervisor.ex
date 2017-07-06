defmodule Exmms2.Client.Supervisor do
  def start_link() do
    import Supervisor.Spec

    children = [
      # Starts a worker by calling: Exmms2.Worker.start_link(arg1, arg2, arg3)
      worker(Exmms2.Client, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :simple_one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
