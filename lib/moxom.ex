defmodule Moxom do
  defmacro __using__(behaviours) do
    quote do
      @before_compile unquote(__MODULE__)
      @after_compile unquote(__MODULE__)
      @behaviours unquote(behaviours)

      import unquote(__MODULE__.DSL)
    end
  end

  defmacro __before_compile__(env) do
    callbacks =
      env.module
      |> Module.get_attribute(:callbacks, [])
      |> Enum.reverse()
      |> Macro.escape()

    behaviours = Module.get_attribute(env.module, :behaviours, [])

    [
      define_impl_module(behaviours, callbacks),
      define_delegates(callbacks)
    ]
  end

  def __after_compile__(env, _) do
    if create_mock?() do
      impl = get_impl(env)
      behaviours = List.flatten(Keyword.get_values(impl.module_info(:attributes), :behaviour))
      mock = get_mock(env)
      Hammox.defmock(mock, for: behaviours)
      Hammox.stub_with(mock, get_impl(env))
    end
  end

  defp define_impl_module(behaviours, callbacks) do
    quote bind_quoted: [behaviours: behaviours, callbacks: callbacks] do
      defmodule Impl do
        for behaviour <- behaviours do
          @behaviour behaviour
        end

        for {call, expr} <- callbacks do
          def(unquote(call), unquote(expr))
        end
      end
    end
  end

  defp define_delegates(callbacks) do
    core =
      if create_mock?() do
        :Mock
      else
        :Impl
      end

    quote bind_quoted: [callbacks: callbacks, core: core] do
      callbacks
      |> Enum.map(fn
        {{:when, _, [call, _guard]}, _expr} -> call
        {call, _expr} -> call
      end)
      |> Enum.map(fn {name, _, args} ->
        args = args |> Enum.with_index() |> Enum.map(&{:"arg_#{elem(&1, 1)}", [], nil})
        {name, args}
      end)
      |> Enum.uniq()
      |> Enum.map(fn {name, args} ->
        defdelegate unquote(name)(unquote_splicing(args)), to: Module.concat(__MODULE__, core)
      end)
    end
  end

  defp get_mock(env) do
    Module.concat(env.module, :Mock)
  end

  defp get_impl(env) do
    Module.safe_concat(env.module, :Impl)
  end

  defp create_mock?() do
    Application.get_env(:moxom, :create_mock, false)
  end
end
