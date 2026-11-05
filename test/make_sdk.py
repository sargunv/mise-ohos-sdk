"""Lay out a miniature OpenHarmony SDK archive, as mise leaves it unpacked.

    make_sdk.py <root> <host> [--omit <entry>]...

The real archive holds one directory per host under a publisher prefix, each a
set of component zips. This writes the same shape with a few small files per
component, so the post-install hook can run against it offline. Each --omit
leaves out a component (such as `ets`) or a toolchains/ entry (such as `hdc`).
"""

from __future__ import annotations

import argparse
import pathlib
import stat
import zipfile

LIBRARY = {"darwin": "libusb_shared.dylib", "linux": "libusb_shared.so"}
ARK = {"darwin": "build-mac", "linux": "build"}


def components(host: str) -> dict[str, dict[str, str | tuple[str]]]:
    """Each component's entries. A string is a file's contents, and a one-item
    tuple is a symbolic link to its target."""
    return {
        "native": {
            "native/build/cmake/ohos.toolchain.cmake": "# toolchain\n",
            "native/llvm/bin/clang": "#!/bin/sh\necho clang\n",
            "native/llvm/bin/clang++": ("clang",),
        },
        "toolchains": {
            "toolchains/hdc": "#!/bin/sh\necho hdc\n",
            f"toolchains/{LIBRARY[host]}": "library\n",
            "toolchains/diff": "#!/bin/sh\nexit 0\n",
            "toolchains/restool": "#!/bin/sh\necho restool\n",
        },
        "ets": {
            f"ets/build-tools/ets-loader/bin/ark/{ARK[host]}/bin/es2abc": "#!/bin/sh\n",
        },
        "js": {"js/api/index.d.ts": "\n"},
        "previewer": {"previewer/bin/Previewer": "#!/bin/sh\n"},
    }


def write_zip(path: pathlib.Path, entries: dict[str, str | tuple[str]]) -> None:
    with zipfile.ZipFile(path, "w") as bundle:
        for name, contents in entries.items():
            info = zipfile.ZipInfo(name)
            if isinstance(contents, tuple):
                info.external_attr = (stat.S_IFLNK | 0o777) << 16
                bundle.writestr(info, contents[0])
            else:
                executable = contents.startswith("#!")
                info.external_attr = (
                    stat.S_IFREG | (0o755 if executable else 0o644)
                ) << 16
                bundle.writestr(info, contents)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=pathlib.Path)
    parser.add_argument("host", choices=sorted(LIBRARY))
    parser.add_argument("--omit", action="append", default=[])
    args = parser.parse_args()

    # The Linux archive also carries the Windows SDK, which the hook discards.
    hosts = [args.host] + (["windows"] if args.host == "linux" else [])
    for host in hosts:
        directory = args.root / "ohos-sdk" / host
        directory.mkdir(parents=True)
        for component, entries in components(
            "linux" if host == "windows" else host
        ).items():
            if component in args.omit:
                continue
            kept = {
                name: contents
                for name, contents in entries.items()
                if pathlib.PurePosixPath(name).name not in args.omit
            }
            write_zip(
                directory / f"{component}-{host}-x64-6.1.0.31-Release.zip", kept
            )
    (args.root / "ohos-sdk" / "README.txt").write_text("publisher notes\n")


if __name__ == "__main__":
    main()
