-- An OpenHarmony SDK tool for mise, which has no registry entry for one.
--
-- The `native` component supplies the cross-compilation SDK, `toolchains`
-- supplies device tools such as hdc, and `ets` supplies the ArkTS compiler that
-- builds a HAP's bytecode. The published SDK also carries the JS toolchain, the
-- previewer, and other components, which this plugin leaves packed and discards.

PLUGIN = {
  name = "ohos-sdk",
  version = "0.1.0",
  description = "OpenHarmony native SDK and device tools",
  author = "sargunv",
  homepage = "https://github.com/sargunv/mise-ohos-sdk",
  license = "BSD-2-Clause",
}
