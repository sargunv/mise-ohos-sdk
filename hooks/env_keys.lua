function PLUGIN:EnvKeys(ctx)
  -- The names the OpenHarmony toolchain and the wider ecosystem use: native builds
  -- read OHOS_SDK_NATIVE, and whole-SDK tools read OHOS_NDK_HOME.
  --
  -- Only bin/ joins PATH, and it holds hdc alone. toolchains/ carries tools with
  -- common names, such as a `diff` that rejects `-r` and exits 0 for files that
  -- differ, so a caller reaches the rest by their path under OHOS_NDK_HOME.
  return {
    { key = "OHOS_SDK_NATIVE", value = ctx.path .. "/native" },
    { key = "OHOS_NDK_HOME", value = ctx.path },
    { key = "PATH", value = ctx.path .. "/bin" },
  }
end
