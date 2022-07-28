defmodule MoxomTest do
  use ExUnit.Case, async: false

  @source_files [
    Path.expand("./support/my_module.ex", __DIR__),
    Path.expand("./support/my_other_module.ex", __DIR__),
  ]

  setup context do
    Application.put_env(:moxom, :create_mock, !!context[:mock])
    Enum.each(@source_files, &Code.compile_file/1)
    {:ok, []}
  end

  @tag mock: false
  test "no mock" do
    assert MyModule.Impl.foo(1) == "1"
    assert MyModule.Impl.foo("1") == 1
    assert MyModule.foo(1) == "1"
    assert MyModule.foo("1") == 1

    assert_raise UndefinedFunctionError, fn ->
      MyModule.Mock.foo(1)
    end
  end

  @tag mock: true
  test "mock without expect" do
    assert MyModule.Mock.foo(1) == "1"
    assert MyModule.Mock.foo("1") == 1
    assert MyModule.foo(1) == "1"
    assert MyModule.foo("1") == 1
  end

  @tag mock: true
  test "mock with expect" do
    Hammox.expect(MyModule.Mock, :foo, fn _ ->
      "2"
    end)

    assert MyModule.foo(1) == "2"
  end

  @tag mock: true
  test "mock inner function" do
    Hammox.expect(MyModule.Mock, :baz, fn -> :error end)
    assert MyModule.bar(1, 2) == 2
  end

  @tag mock: true
  test "indirect mock" do
    Hammox.expect(MyOtherModule.Mock, :x, fn -> 2 end)
    assert MyModule.qux() == 2
  end

  @tag mock: true
  test "mock functions in external behaviours" do
    Hammox.expect(MyModule.Mock, :function_in_behaviour1, fn _ -> :error end)
    assert MyModule.function_in_behaviour1(1) == :error
    assert MyModule.function_in_behaviour2(1) == {:ok, nil}
  end
end
