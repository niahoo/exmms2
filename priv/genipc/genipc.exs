[python_script, xml_def] =
	["gen_api_def.py", "ipc.xml"]
	|> Enum.map(&Path.join(__DIR__, &1))
{data, 0} = System.cmd("python", [python_script, xml_def])
IO.puts data
datafile = Path.join(__DIR__, "ipc.exs")
File.write!(datafile, data)
IO.puts "Wrote IPC API data in #{datafile}\nsuccess"

