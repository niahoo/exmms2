defmodule Exmms2.Mixfile do
  use Mix.Project

  def project do
    [app: :exmms2,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     aliases: aliases(),
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Exmms2.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:decompilerl, github: "niahoo/decompilerl"},
      {:socket, "~> 0.3.12"},
    ]
  end

  defp aliases do
    [
      genipc: &genipc/1,
    ]
  end

  defp genipc(_) do
    # this does not work. We should use a shell script like in npm scripts
    Mix.Task.run("clean") # no work
    Mix.Task.run("run", ["priv/genipc/genipc.exs"])
    Mix.Task.run("compile", ["--force"]) # task already done ...
  end
end
