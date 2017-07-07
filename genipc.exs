System.cmd("rm", ["_build", "-rvf"])
|> elem(0)
|> IO.puts

priv = Path.join([__DIR__, "priv", "genipc"])
[python_script, xml_def] =
  ["gen_api_def.py", "ipc.xml"]
  |> Enum.map(&Path.join(priv, &1))
{data, 0} = System.cmd("python", [python_script, xml_def])
# IO.puts data
datafile = Path.join(priv, "ipc.exs")
File.write!(datafile, data)
IO.puts "\nWrote IPC API data in #{datafile}\nsuccess"
System.halt
