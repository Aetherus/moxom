Code.compiler_options(
  ignore_module_conflict: true,
  no_warn_undefined: [
    {MyModule, :foo, 1},
    {MyModule, :bar, 2},
    {MyModule, :baz, 0},
    {MyModule.Impl, :foo, 1},
    {MyModule.Impl, :bar, 2},
    {MyModule.Impl, :baz, 0},
    {MyModule.Mock, :foo, 1},
    {MyModule.Mock, :bar, 2},
    {MyModule.Mock, :baz, 0},
    {MyOtherModule, :x, 0},
    {MyOtherModule.Impl, :x, 0},
    {MyOtherModule.Mock, :x, 0}
  ]
)

Application.ensure_all_started(:hammox)

ExUnit.start()
ExUnit.configure(seed: 0)
