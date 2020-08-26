[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc)
[![npm](https://img.shields.io/npm/dt/@xpack-dev-tools/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/)

# The xPack GNU Arm Embedded GCC

This open source project provides the platform specific binaries for the
[xPack GNU Arm Embedded GCC](https://xpack.github.io/arm-none-eabi-gcc/);
it is hosted on GitHub as
[`xpack-dev-tools/arm-none-eabi-gcc-xpack`](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack).

This distribution plans to follow the official
[GNU Arm Embedded Toolchain](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm)
distribution, by Arm.

The binaries can be installed automatically as **binary xPacks** or manually as
**portable archives**.

In addition to the package meta data, this project also includes
the build scripts.

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
the latest version of the package is quite easy:

```console
$ xpm install --global @xpack-dev-tools/arm-none-eabi-gcc@latest
```

This command will always install the latest available version,
into the central xPacks repository, which is a platform dependent folder
(check the output of the `xpm` command for the actual folder used on
your platform, and mind the hidden `.content` folder).

This location is configurable using the environment variable
`XPACKS_REPO_FOLDER`; for more details please check the
[xpm folders](https://xpack.github.io/xpm/folders/) page.

xPacks aware tools, like the **GNU MCU Eclipse plug-ins** automatically
identify binaries installed with
`xpm` and provide a convenient method to manage paths.

#### Uninstall

To remove the installed xPack, the command is similar:

```console
$ xpm uninstall --global @xpack-dev-tools/arm-none-eabi-gcc
```

(Note: not yet implemented. As a temporary workaround, simply remove the
`xPacks/@xpack-dev-tools/arm-none-eabi-gcc` folder, or one of the the versioned
subfolders.)

### Manual install

For all platforms, the **xPack GNU Arm Embedded GCC** binaries are released as portable
archives that can be installed in any location.

The archives can be downloaded from the
[GitHub Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/) page.

For more details please read the [Install](https://xpack.github.io/arm-none-eabi-gcc/install/) page.

## Maintainer info

- [How to build](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/README-BUILD.md)
- [How to publish](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/README-PUBLISH.md)

## Support

The quick answer is to use the [xPack forums](https://www.tapatalk.com/groups/xpack/);
please select the correct forum.

For more details please read the [Support](https://xpack.github.io/arm-none-eabi-gcc/support/) page.

## License

The original content is released under the
[MIT License](https://opensource.org/licenses/MIT), with all rights
reserved to [Liviu Ionescu](https://github.com/ilg-ul).

The binary distributions include several open-source components; the
corresponding licenses are available in the installed
`distro-info/licenses` folder.

## Download analytics

- GitHub [`xpack-dev-tools/arm-none-eabi-gcc-xpack`](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/) repo
  - latest xPack release
[![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/arm-none-eabi-gcc-xpack/latest/total.svg)](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/)
  - all xPack releases [![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/arm-none-eabi-gcc-xpack/total.svg)](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/)
  - previous GNU MCU Eclipse all releases [![Github All Releases](https://img.shields.io/github/downloads/gnu-mcu-eclipse/arm-none-eabi-gcc/total.svg)](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc/releases/)
  - [individual file counters](https://www.somsubhra.com/github-release-stats/?username=xpack-dev-tools&repository=arm-none-eabi-gcc-xpack) (grouped per release)
- npmjs.com [`@xpack-dev-tools/arm-none-eabi-gcc`](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/) xPack
  - latest release, per month
[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/)
[![npm](https://img.shields.io/npm/dm/@xpack-dev-tools/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/)
  - all releases [![npm](https://img.shields.io/npm/dt/@xpack-dev-tools/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/)

Credit to [Shields IO](https://shields.io) for the badges and to
[Somsubhra/github-release-stats](https://github.com/Somsubhra/github-release-stats)
for the individual file counters.

