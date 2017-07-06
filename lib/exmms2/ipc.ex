defmodule Exmms2.IPC do
  require Logger
  alias Exmms2.IPC.Compiler

  def protocol_version() do
    unquote(Compiler.ipc().version)
  end

  @min_int64 -9_223_372_036_854_775_808
  @max_int64 9_223_372_036_854_775_807

  defmodule ValidationException do
    defexception [:type, :value, :error, {:message, "Invalid IPC value"}]
    def exception(opts) do
      type = Keyword.fetch!(opts, :type)
      value = Keyword.fetch!(opts, :value)
      %__MODULE__{
        type: type,
        value: value,
        error: {:bad_ipc_value, {type, value}},
        message: "Invalid IPC value #{inspect value} for type #{inspect type}",
      }
    end
  end

  def validate_value!(value, type) do
    if validate_value(value, type) do
      :ok
    else
      raise ValidationException, type: type, value: value
    end
  end

  def validate_value(n, :int) do
    is_integer(n) and n >= @min_int64 and n <= @max_int64
  end

  def validate_value(s, :string),
    do: is_binary(s)

  def validate_value(_, other) do
    Logger.warn("Unknown IPC value type #{inspect other}")
    true
  end

end



