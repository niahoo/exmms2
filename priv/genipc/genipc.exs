[python_script, xml_def] =
	["gen_api_def.py", "ipc.xml"]
	|> Enum.map(&Path.join(__DIR__, &1))
{data, 0} = System.cmd("python", [python_script, xml_def])
data
|> IO.puts
data
|> Code.eval_string
|> IO.inspect
