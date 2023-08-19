[![GitHub package.json version](https://img.shields.io/github/package-json/v/xpack-dev-tools/arm-none-eabi-gcc-xpack)](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/package.json)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/xpack-dev-tools/arm-none-eabi-gcc-xpack)](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/)
[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/arm-none-eabi-gcc.svg?color=blue)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/)
[![license](https://img.shields.io/github/license/xpack-dev-tools/arm-none-eabi-gcc-xpack)](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/LICENSE)

# The xPack GNU Arm Embedded GCC

A standalone cross-platform (Windows/macOS/Linux) **GNU Arm Embedded GCC**
binary distribution, intended for reproducible builds.

In addition to the the binary archives and the package meta data,
this project also includes the build scripts.

## Overview

This open source project is hosted on GitHub as
[`xpack-dev-tools/arm-none-eabi-gcc-xpack`](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack)
and provides the platform specific binaries for the
[xPack GNU Arm Embedded GCC](https://xpack.github.io/arm-none-eabi-gcc/).

The binaries can be installed automatically as **binary xPacks** or manually as
**portable archives**.

## Release schedule

This distribution plans to follow the official
[Arm GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads/)
distribution, by Arm.

## User info

This section is intended as a shortcut for those who plan
to use the GNU Arm Embedded GCC binaries. For full details please read the
[xPack GNU Arm Embedded GCC](https://xpack.github.io/arm-none-eabi-gcc/) pages.

### Easy install

The easiest way to install GNU Arm Embedded GCC is using the **binary xPack**, available as
[`@xpack-dev-tools/arm-none-eabi-gcc`](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc)
from the [`npmjs.com`](https://www.npmjs.com) registry.

#### Prerequisites

A recent [xpm](https://xpack.github.io/xpm/),
which is a portable [Node.js](https://nodejs.org/) command line application
that complements [npm](https://docs.npmjs.com)
with several extra features specific to
**C/C++ projects**.

It is recommended to install/update to the latest version with:

```sh
npm install --location=global xpm@latest
```

For details please follow the instructions in the
[xPack install](https://xpack.github.io/install/) page.

#### Install

With the `xpm` tool available, installing
the latest version of the package and adding it as
a development dependency for a project is quite easy:

```sh
cd my-project
xpm init # Add a package.json if not already present

xpm install @xpack-dev-tools/arm-none-eabi-gcc@latest --verbose

ls -l xpacks/.bin
```

This command will:

- install the latest available version,
into the central xPacks store, if not already there
- add symbolic links to the central store
(or `.cmd` forwarders on Windows) into
the local `xpacks/.bin` folder.

The central xPacks store is a platform dependent
location in the home folder;
check the output of the `xpm` command for the actual
folder used on your platform.
This location is configurable via the environment variable
`XPACKS_STORE_FOLDER`; for more details please check the
[xpm folders](https://xpack.github.io/xpm/folders/) page.

For xPacks aware tools, like the **Eclipse Embedded C/C++ plug-ins**,
it is also possible to install GNU Arm Embedded GCC globally, in the user home folder:

```sh
xpm install --global @xpack-dev-tools/arm-none-eabi-gcc@latest --verbose
```

Eclipse will automatically
identify binaries installed with
`xpm` and provide a convenient method to manage paths.

After install, the package should create a structure like this (macOS files;
only the first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/Library/xPacks/\@xpack-dev-tools/arm-none-eabi-gcc/12.3.1-1.1/.content/
/Users/ilg/Library/xPacks/\@xpack-dev-tools/arm-none-eabi-gcc/12.3.1-1.1/.content/
├── README.md
├── arm-none-eabi
│   ├── bin
│   ├── include
│   ├── lib
│   └── share
├── bin
│   ├── arm-none-eabi-addr2line
│   ├── arm-none-eabi-ar
│   ├── arm-none-eabi-as
│   ├── arm-none-eabi-c++
│   ├── arm-none-eabi-c++filt
│   ├── arm-none-eabi-cpp
│   ├── arm-none-eabi-elfedit
│   ├── arm-none-eabi-g++
│   ├── arm-none-eabi-gcc
│   ├── arm-none-eabi-gcc-12.3.1
│   ├── arm-none-eabi-gcc-ar
│   ├── arm-none-eabi-gcc-nm
│   ├── arm-none-eabi-gcc-ranlib
│   ├── arm-none-eabi-gcov
│   ├── arm-none-eabi-gcov-dump
│   ├── arm-none-eabi-gcov-tool
│   ├── arm-none-eabi-gdb
│   ├── arm-none-eabi-gdb-add-index
│   ├── arm-none-eabi-gdb-add-index-py3
│   ├── arm-none-eabi-gdb-py3
│   ├── arm-none-eabi-gfortran
│   ├── arm-none-eabi-gprof
│   ├── arm-none-eabi-ld
│   ├── arm-none-eabi-ld.bfd
│   ├── arm-none-eabi-lto-dump
│   ├── arm-none-eabi-nm
│   ├── arm-none-eabi-objcopy
│   ├── arm-none-eabi-objdump
│   ├── arm-none-eabi-ranlib
│   ├── arm-none-eabi-readelf
│   ├── arm-none-eabi-size
│   ├── arm-none-eabi-strings
│   └── arm-none-eabi-strip
├── distro-info
│   ├── CHANGELOG.md
│   ├── licenses
│   ├── patches
│   └── scripts
├── include
│   └── gdb
├── lib
│   ├── bfd-plugins
│   ├── gcc
│   ├── libcc1.0.so
│   ├── libcc1.so -> libcc1.0.so
│   └── python3.11
├── libexec
│   ├── gcc
│   ├── libbz2.1.0.8.dylib
│   ├── libcrypt.2.dylib
│   ├── libcrypto.1.1.dylib
│   ├── libexpat.1.6.7.dylib
│   ├── libexpat.1.dylib -> libexpat.1.6.7.dylib
│   ├── libffi.8.dylib
│   ├── libgmp.10.dylib
│   ├── libiconv.2.dylib
│   ├── libisl.15.dylib
│   ├── liblzma.5.dylib
│   ├── libmpc.3.dylib
│   ├── libmpfr.4.dylib
│   ├── libncurses.6.dylib
│   ├── libpanel.6.dylib
│   ├── libpython3.11.dylib
│   ├── libreadline.8.2.dylib
│   ├── libreadline.8.dylib -> libreadline.8.2.dylib
│   ├── libsqlite3.0.dylib
│   ├── libssl.1.1.dylib
│   ├── libz.1.2.13.dylib
│   ├── libz.1.dylib -> libz.1.2.13.dylib
│   └── libzstd.1.5.2.dylib
└── share
    └── gcc-12.3.1

20 directories, 59 files
```

No other files are installed in any system folders or other locations.

#### Uninstall

To remove the links created by xpm in the current project:

```sh
cd my-project

xpm uninstall @xpack-dev-tools/arm-none-eabi-gcc
```

To completely remove the package from the central xPack store:

```sh
xpm uninstall --global @xpack-dev-tools/arm-none-eabi-gcc
```

### Manual install

For all platforms, the **xPack GNU Arm Embedded GCC**
binaries are released as portable
archives that can be installed in any location.

The archives can be downloaded from the
GitHub [Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/)
page.

For more details please read the
[Install](https://xpack.github.io/arm-none-eabi-gcc/install/) page.

### Versioning

The version strings used by the GCC project are three number strings
like `12.3.1`; to this string the xPack distribution adds a four number,
as the Arm version,
but since semver allows only three numbers, all additional ones can
be added only as pre-release strings, separated by a dash,
like `12.3.1-1.1`. The fifth number is the xPack release.
When published as a npm package, the version gets
a sixth number, like `12.3.1-1.1.1`.

Since adherence of third party packages to semver is not guaranteed,
it is recommended to use semver expressions like `^12.3.1` and `~12.3.1`
with caution, and prefer exact matches, like `12.3.1-1.1.1`.

## Maintainer info

For maintainer info, please see the
[README-MAINTAINER](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/README-MAINTAINER.md).

## Support

The quick advice for getting support is to use the GitHub
[Discussions](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/discussions/).

For more details please read the
[Support](https://xpack.github.io/arm-none-eabi-gcc/support/) page.

## License

Unless otherwise stated, the content is released under the terms of the
[MIT License](https://opensource.org/licenses/mit/),
with all rights reserved to
[Liviu Ionescu](https://github.com/ilg-ul).

The binary distributions include several open-source components; the
corresponding licenses are available in the installed
`distro-info/licenses` folder.

## Download analytics

- GitHub [`xpack-dev-tools/arm-none-eabi-gcc-xpack`](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/) repo
  - latest xPack release
[![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/arm-none-eabi-gcc-xpack/latest/total.svg)](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/)
  - all xPack releases [![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/arm-none-eabi-gcc-xpack/total.svg)](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/)
  - previous GNU MCU Eclipse all releases [![Github All Releases](https://img.shields.io/github/downloads/gnu-mcu-eclipse/arm-none-eabi-gcc/total.svg)](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc/releases/)
  - [individual file counters](https://somsubhra.github.io/github-release-stats/?username=xpack-dev-tools&repository=arm-none-eabi-gcc-xpack) (grouped per release)
- npmjs.com [`@xpack-dev-tools/arm-none-eabi-gcc`](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/) xPack
  - latest release, per month
[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/)
[![npm](https://img.shields.io/npm/dm/@xpack-dev-tools/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/)
  - all releases [![npm](https://img.shields.io/npm/dt/@xpack-dev-tools/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/)

Credit to [Shields IO](https://shields.io) for the badges and to
[Somsubhra/github-release-stats](https://github.com/Somsubhra/github-release-stats)
for the individual file counters.
