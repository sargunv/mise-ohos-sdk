local t = dofile(arg[1] .. "/test/helpers.lua")

t.test("names the SDK and puts only bin/ on PATH", function()
  local plugin = t.load("env_keys")
  t.eq(plugin:EnvKeys({ path = "/sdk", version = "6.1" }), {
    { key = "OHOS_SDK_NATIVE", value = "/sdk/native" },
    { key = "OHOS_NDK_HOME", value = "/sdk" },
    { key = "PATH", value = "/sdk/bin" },
  }, "environment")
end)

t.done()
