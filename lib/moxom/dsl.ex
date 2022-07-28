defmodule Moxom.DSL do
  defmacro defbehaviour(do: block) do
    quote do
      defmodule Behaviour, do: unquote(block)
      @behaviours [__MODULE__.Behaviour | @behaviours]

      Module.register_attribute(__MODULE__, :callbacks, accumulate: true)
    end
  end

  defmacro defcb(call, expr \\ nil) do
    quote bind_quoted: [call: Macro.escape(call), expr: Macro.escape(expr)] do
      @callbacks {call, expr}
    end
  end
end
