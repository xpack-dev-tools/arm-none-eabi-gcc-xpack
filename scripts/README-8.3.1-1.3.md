# xPack GNU Arm Embedded GCC

This is the **xPack** version of the
[GNU Arm Embedded Toolchain](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm).

For details, see
[The xPack GNU Arm Embedded GCC](https://xpack.github.io/arm-none-eabi-gcc/) pages.

## Easy install

The **xPack Arm Embedded GCC** toolchain is also available as a
binary [xPack](https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc)
and can be conveniently installed with [xpm](https://www.npmjs.com/package/xpm):

```sh
xpm install --global @xpack-dev-tools/arm-none-eabi-gcc@8.3.1-1.3
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

- GNU/Linux: all binaries were built with GCC 7.4, running in a CentOS 6
  Docker container
- Windows: all binaries were built with mingw-w64 GCC 7.4, running in a
  CentOS 6 Docker container
- macOS: most binaries were built with GCC 7.4, running in a separate
  folder on macOS 10.10.5; GDB cannot be compiled with GCC, so Apple
  clang was used.

Partial support for Python3 was added to GDB for GNU/Linux and macOS;
not yet available on Windows ([24469](https://sourceware.org/bugzilla/show_bug.cgi?id=24469)).

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


