defmodule MyOtherModule do
  use Moxom

  defbehaviour do
    @callback x() :: integer()
  end

  defcb x(), do: 1
end
