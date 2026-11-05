# mise-ohos-sdk

A [mise](https://mise.jdx.dev) plugin that installs the
[OpenHarmony](https://www.openharmony.cn) SDK from its public release archives.

## Usage

The mise registry has no entry for the SDK, so name this plugin in `[plugins]`,
pinned to a tag:

```toml
[plugins]
ohos-sdk = "https://github.com/sargunv/mise-ohos-sdk#v0.1.0"

[tools]
ohos-sdk = "6.1"
```

`mise ls-remote ohos-sdk` lists the releases, which are the `-Release`
directories of the
[release index](https://repo.huaweicloud.com/openharmony/os/).

mise doesn't replace an installed plugin when its `[plugins]` entry changes. To
pick up a new tag, or to replace a plugin installed some other way, run
`mise plugins install --force ohos-sdk`.

## What it installs

The SDK unpacks into the tool's install directory:

- `native/`: the cross-compilation SDK, with LLVM, the sysroot, and
  `build/cmake/ohos.toolchain.cmake`.
- `toolchains/`: device and packaging tools, such as `hdc`, `restool`, and the
  signing tools in `lib/`.
- `ets/`: the ArkTS toolchain, whose `es2abc` compiles an application's modules
  into the bytecode that a HAP holds.
- `bin/`: a link to `toolchains/hdc`.

The published archive's other components, such as the JS toolchain and the
previewer, are discarded.

The plugin sets:

| Variable          | Value                |
| ----------------- | -------------------- |
| `OHOS_SDK_NATIVE` | `<install>/native`   |
| `OHOS_NDK_HOME`   | `<install>`          |
| `PATH`            | adds `<install>/bin` |

Only `hdc` goes on `PATH`. `toolchains/` holds tools with common names, such as
a `diff` that rejects `-r` and exits 0 for files that differ, so call the rest
by path, as in `"$OHOS_NDK_HOME/toolchains/restool"`.

## Requirements

- macOS (arm64 or x86_64) or x86_64 Linux. OpenHarmony publishes no SDK for
  arm64 Linux, and the post-install step needs a POSIX shell, so Windows isn't
  supported.
- `python3`, which unpacks the SDK's component archives with their symbolic
  links intact.
- On Linux, `hdc` loads `libatomic.so.1`, which minimal images such as
  `debian:stable-slim` lack (`apt-get install libatomic1`).

## Development

See [AGENTS.md](AGENTS.md).

## License

MIT. See [LICENSE](LICENSE). The plugin started in
[MapLibre Native FFI](https://github.com/maplibre/maplibre-native-ffi).
