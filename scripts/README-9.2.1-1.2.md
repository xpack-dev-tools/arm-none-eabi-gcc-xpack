# xPack GNU Arm Embedded GCC

This is the **xPack** version of the
[GNU Arm Embedded Toolchain](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm).

For details, see
[The xPack GNU Arm Embedded GCC](https://xpack.github.io/arm-none-eabi-gcc/) pages.

## Easy install

The **xPack Arm Embedded GCC** toolchain is also available as a
binary [xPack](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc)
and can be conveniently installed with [xpm](https://www.npmjs.com/package/xpm):

```console
$ xpm install --global @xpack-dev-tools/arm-none-eabi-gcc@9.2.1-1.2.1
```

For more details on how to install the toolchain, please see
[How to install the Arm toolchain?](http://xpack.github.io/arm-none-eabi-gcc/install/) page.

## Compliance

This release closely follows the official Arm distribution, as described
in the original Arm release text files:

- `distro-info/arm-readme.txt`
- `distro-info/arm-release.txt`

## Changes

Compared to the Arm distribution, the build procedure is more or less the
same and there should be no functional differences.

## Compatibility

The binaries were built using
[xPack Build Box (XBB)](https://github.com/xpack/xpack-build-box), a set
of build environments based on slightly older distributions, that should be
compatible with most recent systems.

- Intel GNU/Linux: all binaries were built with GCC 9.3, running in an
  Ubuntu 12.04 LTS Docker container
- Arm GNU/Linux: all binaries were built with GCC 9.3, running in on Ubuntu
  16.04.6 LTS
- Windows: all binaries were built with mingw-w64 GCC 9.3, running in a
  Ubuntu 12.04 LTS Docker container
- macOS: most binaries were built with GCC 9.3, running in a separate
  folder on macOS 10.10.5; GDB cannot be compiled with GCC, so Apple
  clang was used.

## Shared libraries

On all platforms the packages are standalone, and expect only the standard
C/C++ runtime to be present on the host.

All dependencies that are build as shared libraries are copied locally in the
same folder as the executable.

### `rpath`

On GNU/Linux the binaries are adjusted to use a relative run path:

```console
$ readelf -d library.so | grep runpath
 0x000000000000001d (RUNPATH)            Library runpath: [$ORIGIN]
```

Please note that in the GNU ld.so search strategy, the `DT_RUNPATH` has
lower priority than `LD_LIBRARY_PATH`, so if this later one is set
in the environment, it might interfere with the xPack binaries.

### `@executable_path`

Similarly, on macOS, the dynamic libraries are adjusted with `otool` to use a
relative path.

## Python

Support for Python scripting was added to GDB. This distribution provides
two separate binaries,
`arm-none-eabi-gdb-py` with Python 2.7 support, and `arm-none-eabi-gdb-py3` with
support for Python 3.7.

Note: Support for Python3 is not yet available on Windows 
([24469](https://sourceware.org/bugzilla/show_bug.cgi?id=24469)).

Mode details on the prerequisites of running GDB with Python support are
available from
[GDB with Python support](https://xpack.github.io/arm-none-eabi-gcc/python/).

## Text User Interface (TUI)

Support for TUI was added to GDB. The `ncurses` library (v6.2) was added to
the distribution.

Note: TUI is not available on Windows.

## Build

The scripts used to build this distribution are in:

- `distro-info/scripts`

For the prerequisites and more details on the build procedure, please see the
[How to build?](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/README-BUILD.md) page.

## Documentation

The original PDF documentation is available in the `share/doc` folder.

## More info

For more info, please see the xPack project site:

  http://xpack.github.io/arm-none-eabi-gcc/

Thank you for using open source software,

Liviu Ionescu
