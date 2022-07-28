defmodule MyBehaviour1 do
  @callback function_in_behaviour1(any()) :: {:ok, any()} | :error
end

defmodule MyBehaviour2 do
  @callback function_in_behaviour2(any()) :: {:ok, any()} | :error
end
