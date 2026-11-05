# vfox-ohos-sdk

A mise (vfox) plugin that installs the OpenHarmony SDK.

## Project map

```text
metadata.lua         Plugin name, version, and description
hooks/
  available.lua      Lists releases from the Huawei Cloud mirror, newest first
  pre_install.lua    Picks the archive for this host and its published SHA-256
  post_install.lua   Keeps the native, toolchains, and ets components; links hdc into bin/
  env_keys.lua       Sets OHOS_SDK_NATIVE and OHOS_NDK_HOME, and puts bin/ on PATH
lib/extract_zip.py   Unzips a component, keeping symbolic links and modes
types/               LuaCATS definitions of mise's vfox runtime, for lua-language-server
test/
  run.sh             Runs every *_test.lua
  helpers.lua        Loads a hook with stubbed mise modules; assertions
  make_sdk.py        Lays out a miniature SDK archive for the post-install test
  fixtures/          A snapshot of the release index
```

## Dev tool commands

- `mise run test`: run the hooks against stubs and a miniature archive, offline.
- `mise run check`: run every formatter and linter (hk, which drives dprint,
  StyLua, shfmt, ruff, shellcheck, lua-language-server, and jactionlint).
- `mise run fix`: apply formatters and auto-fixable lints.

To try a change against the real SDK, link the checkout and install it (a
multi-gigabyte download):

```sh
mise plugins link --force ohos-sdk .
mise install ohos-sdk@6.1
```

Relink to the released plugin afterward with
`mise plugins install --force ohos-sdk`, because the link is global.

## Project invariants

<!-- List non-negotiable rules for this project -->
