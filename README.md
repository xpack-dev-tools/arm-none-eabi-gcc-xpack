[![GitHub release (latest by date)](https://img.shields.io/github/v/release/xpack-dev-tools/arm-none-eabi-gcc-xpack)](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases)
[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc)

# The xPack GNU Arm Embedded GCC

A standalone cross-platform (Windows/macOS/Linux) GCC
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
[GNU Arm Embedded Toolchain](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm)
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

The only requirement is a recent
`xpm`, which is a portable
[Node.js](https://nodejs.org) command line application. To install it,
follow the instructions from the
[xpm](https://xpack.github.io/xpm/install/) page.

#### Install

With the `xpm` tool available, installing
the latest version of the package and adding it as
a dependency for a project is quite easy:

```sh
cd my-project
xpm init # Only at first use.

xpm install @xpack-dev-tools/arm-none-eabi-gcc@latest

ls -l xpacks/.bin
```

This command will:

- install the latest available version,
into the central xPacks store, if not already there
- add symbolic links to the central store
(or `.cmd` forwarders on Windows) into
the local `xpacks/.bin` folder.

The central xPacks store is a platform dependent
folder; check the output of the `xpm` command for the actual
folder used on your platform).
This location is configurable via the environment variable
`XPACKS_REPO_FOLDER`; for more details please check the
[xpm folders](https://xpack.github.io/xpm/folders/) page.

For xPacks aware tools, like the **Eclipse Embedded C/C++ plug-ins**,
it is also possible to install GNU Arm Embedded GCC globally, in the user home folder:

```sh
xpm install --global @xpack-dev-tools/arm-none-eabi-gcc@latest
```

Eclipse will automatically
identify binaries installed with
`xpm` and provide a convenient method to manage paths.

#### Uninstall

To remove the links from the current project:

```sh
cd my-project

xpm uninstall @xpack-dev-tools/arm-none-eabi-gcc
```

To completely remove the package from the global store:

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

The version strings used by the GCC project are three number string
like `10.3.1`; to this string the xPack distribution adds a four number,
as the Arm version,
but since semver allows only three numbers, all additional ones can
be added only as pre-release strings, separated by a dash,
like `10.3.1-1.1`. The fifth number is the xPack release.
When published as a npm package, the version gets
a sixth number, like `10.3.1-1.1.1`.

Since adherance of third party packages to semver is not guaranteed,
it is recommended to use semver expressions like `^10.3.1` and `~10.3.1`
with caution, and prefer exact matches, like `10.3.1-1.1.1`.

### Windows drivers

Most JTAG probes require separate drivers on Windows.
For more details please read the
[Install](https://xpack.github.io/arm-none-eabi-gcc/install/) page.

### GNU/Linux UDEV subsystem

For the JTAG probes implemented as USB devices (actually most of them),
the last installation step on GNU/Linux is to configure the UDEV subsystem.

For more details please read the
[Install](https://xpack.github.io/arm-none-eabi-gcc/install/) page.

## Maintainer info

- [How to build](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/README-BUILD.md)
- [How to make new releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/README-RELEASE.md)
- [Developer info](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/README-DEVELOP.md)

## Support

The quick answer is to use the
[xPack forums](https://www.tapatalk.com/groups/xpack/);
please select the correct forum.

For more details please read the
[Support](https://xpack.github.io/arm-none-eabi-gcc/support/) page.

## License

The original content is released under the
[MIT License](https://opensource.org/licenses/MIT), with all rights
reserved to [Liviu Ionescu](https://github.com/ilg-ul/).

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
