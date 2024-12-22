---

title:  xPack GNU Arm Embedded GCC v10.3.1-2.1 released
sidebar: arm-none-eabi-gcc

summary: "Version **10.3.1-2.1** is a new release; it follows the upstream Arm release 10.3-2021.10 from October 21, 2021."

arm_version: 10.3-2021.10
arm_date: October 21, 2021
version: 10.3.1-2.1
npm_subversion: 1

download_url: https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/tag/v10.3.1-2.1/

date: 2021-10-25 18:26:11 +0300

redirect_to: https://xpack-dev-tools.github.io/arm-none-eabi-gcc-xpack/blog/2021/10/25/arm-none-eabi-gcc-v10-3-1-2-1-released/

comments: true

categories:
  - releases
  - arm-none-eabi-gcc

tags:
  - releases
  - arm
  - arm-none-eabi-gcc
  - gcc
  - binaries
  - c++
  - exceptions

---

The [xPack GNU Arm Embedded GCC](https://xpack.github.io/dev-tools/arm-none-eabi-gcc/)
is a standalone cross-platform binary distribution of
[GNU Arm Embedded Toolchain](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm).

There are separate binaries for **Windows** (x64 and x86),
**macOS** (x64) and **GNU/Linux** (x64 and x86, arm64 and arm).

{% include note.html content="The main targets for the GNU/Linux Arm
binaries are the **Raspberry Pi** class devices (armv7l and aarch64;
armv6 is not supported)." %}

{% include note.html content="Release 10.3.1-1.1, corresponding to Arm release 10.3-2021.07, was skipped." %}

## Download

The binary files are available from [GitHub Releases]({{ page.download_url }}).

## Prerequisites

- x86/x64 GNU/Linux: any system with **GLIBC 2.15** or higher
  (like Ubuntu 12 or later, Debian 8 or later, RedHat/CentOS 7 later,
  Fedora 20 or later, etc)
- arm64/arm GNU/Linux: any system with **GLIBC 2.23** or higher
  (like Ubuntu 16 or later, Debian 9 or later, RedHat/CentOS 8 or later,
  Fedora 24 or later, etc)
- x86/x64 Windows: Windows 7 with the Universal C Runtime
  ([UCRT](https://support.microsoft.com/en-us/topic/update-for-universal-c-runtime-in-windows-c0514201-7fe6-95a3-b0a5-287930f3560c)),
  Windows 8, Windows 10
- x64 macOS: 10.13 or later

## Install

The full details of installing the **xPack GNU Arm Embedded GCC** on various platforms
are presented in the separate [Install]({{ site.baseurl }}/dev-tools/arm-none-eabi-gcc/install/) page.

### Easy install

The easiest way to install Arm Embedded GCC is with
[`xpm`]({{ site.baseurl }}/xpm/)
by using the **binary xPack**, available as
[`@xpack-dev-tools/arm-none-eabi-gcc`](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc)
from the [`npmjs.com`](https://www.npmjs.com) registry.

With the `xpm` tool available, installing
the latest version of the package and adding it as
a dependency for a project is quite easy:

```sh
cd my-project
xpm init # Only at first use.

xpm install @xpack-dev-tools/arm-none-eabi-gcc@latest

ls -l xpacks/.bin
```

To install this specific version, use:

```sh
xpm install @xpack-dev-tools/arm-none-eabi-gcc@{{ page.version }}.{{ page.npm_subversion }}
```

For xPacks aware tools, like the **Eclipse Embedded C/C++ plug-ins**,
it is also possible to install Arm Embedded GCC globally, in the user home folder.

```sh
xpm install --global @xpack-dev-tools/arm-none-eabi-gcc@latest --verbose
```

Eclipse will automatically
identify binaries installed with
`xpm` and provide a convenient method to manage paths.

### Uninstall

To remove the links from the current project:

```sh
cd my-project

xpm uninstall @xpack-dev-tools/arm-none-eabi-gcc
```

To completely remove the package from the central xPacks store:

```sh
xpm uninstall --global @xpack-dev-tools/arm-none-eabi-gcc
```

## Compliance

The xPack GNU Arm Embedded GCC generally follows the official
[Arm Embedded GCC](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads/) releases.

The current version is based on:

- [GNU Arm Embedded Toolchain](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm)
release **{{ page.arm_version }}** from {{ page.arm_date }} and uses the
`gcc-arm-none-eabi-{{ page.arm_version }}-src.tar.bz2` source invariant.
It includes:
  - GCC 10.3.1
  - binutils 2.36
  - newlib 4.1.0
  - GDB 10.2

For more details see the original Arm release text files:

- `distro-info/arm-readme.txt`
- `distro-info/arm-release.txt`

## Supported libraries

The supported libraries are:

```console
$ arm-none-eabi-gcc -print-multi-lib
.;
arm/v5te/softfp;@marm@march=armv5te+fp@mfloat-abi=softfp
arm/v5te/hard;@marm@march=armv5te+fp@mfloat-abi=hard
thumb/nofp;@mthumb@mfloat-abi=soft
thumb/v7/nofp;@mthumb@march=armv7@mfloat-abi=soft
thumb/v7+fp/softfp;@mthumb@march=armv7+fp@mfloat-abi=softfp
thumb/v7+fp/hard;@mthumb@march=armv7+fp@mfloat-abi=hard
thumb/v7-r+fp.sp/softfp;@mthumb@march=armv7-r+fp.sp@mfloat-abi=softfp
thumb/v7-r+fp.sp/hard;@mthumb@march=armv7-r+fp.sp@mfloat-abi=hard
thumb/v6-m/nofp;@mthumb@march=armv6s-m@mfloat-abi=soft
thumb/v7-m/nofp;@mthumb@march=armv7-m@mfloat-abi=soft
thumb/v7e-m/nofp;@mthumb@march=armv7e-m@mfloat-abi=soft
thumb/v7e-m+fp/softfp;@mthumb@march=armv7e-m+fp@mfloat-abi=softfp
thumb/v7e-m+fp/hard;@mthumb@march=armv7e-m+fp@mfloat-abi=hard
thumb/v7e-m+dp/softfp;@mthumb@march=armv7e-m+fp.dp@mfloat-abi=softfp
thumb/v7e-m+dp/hard;@mthumb@march=armv7e-m+fp.dp@mfloat-abi=hard
thumb/v8-m.base/nofp;@mthumb@march=armv8-m.base@mfloat-abi=soft
thumb/v8-m.main/nofp;@mthumb@march=armv8-m.main@mfloat-abi=soft
thumb/v8-m.main+fp/softfp;@mthumb@march=armv8-m.main+fp@mfloat-abi=softfp
thumb/v8-m.main+fp/hard;@mthumb@march=armv8-m.main+fp@mfloat-abi=hard
thumb/v8-m.main+dp/softfp;@mthumb@march=armv8-m.main+fp.dp@mfloat-abi=softfp
thumb/v8-m.main+dp/hard;@mthumb@march=armv8-m.main+fp.dp@mfloat-abi=hard
thumb/v8.1-m.main+mve/hard;@mthumb@march=armv8.1-m.main+mve@mfloat-abi=hard
```

## Changes

Compared to the official Arm version, there should be no functional changes.

### Python

Support for Python scripting was added to GDB. This distribution provides
a separate binary, `arm-none-eabi-gdb-py3` with
support for **Python 3.7**.

The Python 3 run-time is included, so GDB does not need any version of
Python to be installed, and is insensitive to the presence of other
versions.

Support for Python 2 was discontinued.

### Text User Interface (TUI)

Support for TUI was added to GDB. The `ncurses` library (v6.2) was added to
the distribution.

{% include note.html content="TUI is not available on Windows." %}

## Bug fixes

- none

## Enhancements

- none

## Known problems

- none

## Shared libraries

On all platforms the packages are standalone, and expect only the standard
runtime to be present on the host.

All dependencies that are build as shared libraries are copied locally
in the `libexec` folder (or in the same folder as the executable for Windows).

### `DT_RPATH` and `LD_LIBRARY_PATH`

On GNU/Linux the binaries are adjusted to use a relative path:

```console
$ readelf -d library.so | grep runpath
 0x000000000000001d (RPATH)            Library rpath: [$ORIGIN]
```

In the GNU ld.so search strategy, the `DT_RPATH` has
the highest priority, higher than `LD_LIBRARY_PATH`, so if this later one
is set in the environment, it should not interfere with the xPack binaries.

Please note that previous versions, up to mid-2020, used `DT_RUNPATH`, which
has a priority lower than `LD_LIBRARY_PATH`, and does not tolerate setting
it in the environment.

### `@executable_path`

Similarly, on macOS, the binaries are adjusted with `otool` to use a
relative path.

## Documentation

The original documentation is available in the `share/doc` folder.

## Build

The binaries for all supported platforms
(Windows, macOS and GNU/Linux) were built using the
[xPack Build Box (XBB)](https://xpack.github.io/xbb/), a set
of build environments based on slightly older distributions, that should be
compatible with most recent systems.

The scripts used to build this distribution are in:

- `distro-info/scripts`

For the prerequisites and more details on the build procedure, please see the
[README-MAINTAINER](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/README-MAINTAINER.md) page.

## CI tests

Before publishing, a set of simple tests were performed on an exhaustive
set of platforms. The results are available from:

- [GitHub Actions](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/actions/)
- [Travis CI](https://app.travis-ci.com/github/xpack-dev-tools/arm-none-eabi-gcc-xpack/builds/)

## Tests

The binaries were tested on a variety of platforms,
but mainly to check the integrity of the
build, not the compiler functionality.

## Checksums

The SHA-256 hashes for the files are:

```txt
703dcbbbeaf6f2577cb7b3677072fa176b9d7e55256735e0b770b90952c626d9
xpack-arm-none-eabi-gcc-10.3.1-2.1-darwin-x64.tar.gz

7a264f45863f0006ab65da66cd4683b311977f6cda4e7ef18dde5e70717b6ea1
xpack-arm-none-eabi-gcc-10.3.1-2.1-linux-arm.tar.gz

f78c2ec2177d29a005e43eb05aa36f361428f0d607b80046b3e032a08ae8232c
xpack-arm-none-eabi-gcc-10.3.1-2.1-linux-arm64.tar.gz

a53a7a371dfd2385a3c67eceb4875e99ccaa8b2c6f29942fb806b597ca07b1d6
xpack-arm-none-eabi-gcc-10.3.1-2.1-linux-ia32.tar.gz

eb4c7cb16ac1ab7d629ce807847692d5add9f13f23a3196fc545acc6f410a8cf
xpack-arm-none-eabi-gcc-10.3.1-2.1-linux-x64.tar.gz

a362ae0bbf710b7941ff41fd9ae21e079941594f310da90f4d7cd1f355a67071
xpack-arm-none-eabi-gcc-10.3.1-2.1-win32-ia32.zip

17c78c88efba6b6f3988b216044db908570af70392977c7a4680a5f08e098b61
xpack-arm-none-eabi-gcc-10.3.1-2.1-win32-x64.zip

```

## Deprecation notices

### 32-bit support

Support for 32-bit x86 GNU/Linux and x86 Windows will most probably
be dropped in 2022. Support for 32-bit Arm GNU/Linux will be preserved
for a while, due to the large user base of 32-bit Raspberry Pi systems.

### GNU/Linux minimum requirements

Support for RedHat 7 will most probably be dropped in 2022, and the
minimum requirement will be raised to GLIBC 2.27, available starting
with Ubuntu 18 and RedHat 8.

## Download analytics

- GitHub [xpack-dev-tools/arm-none-eabi-gcc-xpack](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/)
  - this release [![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/arm-none-eabi-gcc-xpack/v{{ page.version }}/total.svg)](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/v{{ page.version }}/)
  - all xPack releases [![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/arm-none-eabi-gcc-xpack/total.svg)](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/)
  - all GNU MCU Eclipse releases [![Github All Releases](https://img.shields.io/github/downloads/gnu-mcu-eclipse/arm-none-eabi-gcc/total.svg)](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc/releases/)
  - [individual file counters](https://somsubhra.github.io/github-release-stats/?username=xpack-dev-tools&repository=arm-none-eabi-gcc-xpack) (grouped per release)
- npmjs.com [@xpack-dev-tools/arm-none-eabi-gcc](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc)
  - latest releases [![npm](https://img.shields.io/npm/dw/@xpack-dev-tools/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/)
  - all @xpack-dev-tools releases [![npm](https://img.shields.io/npm/dt/@xpack-dev-tools/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc/)
  - all @gnu-mcu-eclipse releases [![npm](https://img.shields.io/npm/dt/@gnu-mcu-eclipse/arm-none-eabi-gcc.svg)](https://www.npmjs.com/package/@gnu-mcu-eclipse/arm-none-eabi-gcc/)

Credit to [Shields IO](https://shields.io) for the badges and to
[Somsubhra/github-release-stats](https://github.com/Somsubhra/github-release-stats)
for the individual file counters.
