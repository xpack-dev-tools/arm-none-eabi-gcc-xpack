# Patches

## gdb-8.2.patch

To allow GDB to be compiled with clang on macOS 10.10, since compiling
with GCC 7.4 results in a binary that fails with SIGABRT.

## gcc-8.2.1-patch

To fix a mingw issue preventing files to be written.

## python-2.7.13.patch, python-2.7.13.amd64.patch

Remove the `hypot` macro, to allow it to compile for GDB inclusion.

## python-3.7.2.h

Not a patch, a file copied from the running distribution, to simplify
the build, since a configure is not possible when compiling the 
Python library for GDB.

## binutils-gdb-2.32.patch

To add `install-strip` to `readline/Makefile.in`.

## binutils-2.31.patch

To fix the objcopy bug that used 64-bit addresses on 32-bit builds.

## binutils-2.30.patch & binutils-2.28.patch

Add `install-strip:` to `readline/Makefile.in`.