defmodule MyModule do
  use Moxom, [MyBehaviour1, MyBehaviour2]

  defbehaviour do
    @callback foo(integer() | String.t()) :: integer() | String.t()
    @callback bar(any(), any()) :: any()
    @callback baz() :: :ok | :error
    @callback qux() :: any()
  end

  defcb foo(n) when is_integer(n), do: Integer.to_string(n)
  defcb foo(s), do: String.to_integer(s)
  defcb bar(x, y) do
    case MyModule.baz() do
      :ok -> x
      :error -> y
    end
  end

  defcb baz() do
    :ok
  end

  defcb qux(), do: MyOtherModule.x()

  defcb function_in_behaviour1(_), do: {:ok, nil}

  defcb function_in_behaviour2(_), do: {:ok, nil}
end
