GNU Toolchain 11.2-2022.02
GNU toolchain for the Arm architecture
GCC Version: 11.2

Table of Contents
* Available toolchain targets
* Installing executables on Linux
* Installing executables on macOS
* Installing executables on Windows
* Invoking GCC
* Architecture options usage
* Available multilibs
* C Libraries usage
* Linker scripts & startup code
* Samples
* GDB Server for CMSIS-DAP based hardware debugger


* Available toolchain targets *

Depending on the host platform, the available toolchain targets can be one of:
    arm-none-eabi
    arm-none-linux-gnueabi
    arm-none-linux-gnueabihf
    aarch64-none-elf
    aarch64_be-none-elf
    aarch64-none-linux-gnu
    aarch64_be-none-linux-gnu
In this document, <TRIPLE> is one of the above toolchain targets.


* Installing executables on Linux *

Unpack the tarball to the install directory, like this:
    On x86_64:
    $ cd ${install_dir} && tar xf gcc-arm-11.2-2022.02-x86_64-<TRIPLE>.tar.xz
    On aarch64:
    $ cd ${install_dir} && tar xf gcc-arm-11.2-2022.02-aarch64-<TRIPLE>.tar.xz

If you want to use gdb python build (for example, <TRIPLE>-gdb-py), then
install python2.7.


* Installing executables on macOS *

Unpack the tarball to the install directory, like this:
    On darwin-x86_64:
    $ cd ${install_dir} && tar xf gcc-arm-11.2-2022.02-darwin-x86_64-<TRIPLE>.tar.xz


* Installing executables on Windows *

Run the installer:
    gcc-arm-11.2-2022.02-mingw-w64-i686-<TRIPLE>.exe
and follow the instructions. The installer can also be run on the command line.
When run on the command-line, the following options can be set:
  - /S Run in silent mode
  - /P Adds the installation bin directory to the system PATH
  - /R Adds an InstallFolder registry entry for the install.

For example, to install the tools silently, amend users PATH and add registry
entry:

    > gcc-arm-11.2-2022.02-mingw-w64-i686-<TRIPLE>.exe /S /P /R

The toolchain in Windows zip package is a backup to Windows installer for
those who cannot run the installer.  You must decompress the zip package
and then invoke it following instructions in the next section.

To use gdb python build (for example, arm-none-eabi-gdb-py), you must install 32 bit
python2.7 irrespective of 32 or 64 bit Windows.  Please get the package from
https://www.python.org/downloads/.

* Invoking GCC *
On Linux and macOS, either invoke with the complete path like this:

    $ ${install_dir}/gcc-arm-11.2-2022.02-<HOST_ARCH>-aarch64-none-elf/bin/aarch64-none-elf-gcc
    where, depending on the host, <HOST_ARCH> is one of:
    x86_64
    aarch64
    darwin-x86_64

Or set the path and then invoke the toolchain like this:

    $ export PATH=$PATH:${install_dir}/gcc-arm-11.2-2022.02-<HOST_ARCH>-aarch64-none-elf/bin
    $ aarch64-none-elf-gcc --version

On Windows, although the above approaches also work, it can be more
convenient to either have the installer register environment variables, or run
INSTALL_DIR\bin\gccvar.bat to set environment variables for the current cmd.

For Windows zip package, after decompression we can invoke the toolchain either with
complete path like this:
TOOLCHAIN_UNZIP_DIR\bin\aarch64-none-elf-gcc
or run TOOLCHAIN_UNZIP_DIR\bin\gccvar.bat to set environment variables for the
current cmd.

* Architecture options usage *

This toolchain is built and optimized for Arm processors.
This section describes how to invoke GCC/G++ with the correct command line
options for variants of Cortex-A, Cortex-R and Cortex-M processors.

    $ aarch64-none-elf-gcc [-mthumb] -mcpu=CPU[+extension...] -mfloat-abi=ABI

-mcpu:
For the permissible CPU names and extensions, see the GCC online manual:
https://gcc.gnu.org/onlinedocs/gcc-11.2.0/gcc/ARM-Options.html#index-mcpu-2
Use the optional extension name with -mcpu to disable the extensions that are
not present in your CPU implementation.

By default, -mfpu=auto and this enables the compiler to automatically select
the floating-pointing and Advanced SIMD instructions based on the -mcpu option
and extension.

-mfloat-abi:
If floating-point or Advanced SIMD instructions are present, then use the
-mfloat-abi option to control the floating-point ABI, or use -mfloat-abi=soft
to disable floating-point and Advanced SIMD instructions.
For the permissible values of -mfloat-abi, see the GCC online manual:
https://gcc.gnu.org/onlinedocs/gcc-11.2.0/gcc/ARM-Options.html#index-mfloat-abi

-mthumb:
When using processors that can execute in Arm state and Thumb state, use -mthumb
to generate code for Thumb state.

Examples with no floating-point and Advanced SIMD instructions:
    $ arm-none-eabi-gcc -mcpu=cortex-m7+nofp
    $ arm-none-eabi-gcc -mcpu=cortex-r5+nofp -mthumb
    $ arm-none-eabi-gcc -mcpu=cortex-a53+nofp -mthumb
    $ arm-none-eabi-gcc -mcpu=cortex-a57 -mfloat-abi=soft -mthumb

Examples with single-precision floating-point with soft-float ABI:
    $ arm-none-eabi-gcc -mcpu=cortex-m7+nofp.dp -mfloat-abi=softfp
    $ arm-none-eabi-gcc -mcpu=cortex-r5+nofp.dp -mfloat-abi=softfp -mthumb

Examples with single-precision floating-point with hard-float ABI:
    $ arm-none-eabi-gcc -mcpu=cortex-m7+nofp.dp -mfloat-abi=hard
    $ arm-none-eabi-gcc -mcpu=cortex-r5+nofp.dp -mfloat-abi=hard -mthumb

Examples with double-precision floating-point with soft-float ABI:
    $ arm-none-eabi-gcc -mcpu=cortex-m7 -mfloat-abi=softfp
    $ arm-none-eabi-gcc -mcpu=cortex-r5 -mfloat-abi=softfp -mthumb

Examples with double-precision floating-point with hard-float ABI:
    $ arm-none-eabi-gcc -mcpu=cortex-m7 -mfloat-abi=hard
    $ arm-none-eabi-gcc -mcpu=cortex-r5 -mfloat-abi=hard -mthumb

Example with floating-point and Advanced SIMD instructions with soft-float ABI:
    $ arm-none-eabi-gcc -mcpu=cortex-a53 -mfloat-abi=softfp -mthumb

Example with floating-point and Advanced SIMD instructions with hard-float ABI:
    $ arm-none-eabi-gcc -mcpu=cortex-a53 -mfloat-abi=hard -mthumb

Example with MVE and floating-point with soft-float ABI:
    $ arm-none-eabi-gcc -mcpu=cortex-m55 -mfloat-abi=softfp

Example with MVE and floating-point with hard-float ABI:
    $ arm-none-eabi-gcc -mcpu=cortex-m55 -mfloat-abi=hard

* Available multilibs *

GNU Toolchain 11.2-2022.02 offers a set of multilibs.

To list all multilibs supported by the arm-none-eabi toolchain:

    $ aarch64-none-elf-gcc --print-multi-lib

To check which multilib is selected by the arm-none-eabi toolchain
based on -mthumb, -mcpu, -mfpu and -mfloat-abi command line options:

    $ aarch64-none-elf-gcc [-mthumb] -mcpu=CPU -mfpu=FPU -mfloat-abi=ABI --print-multi-dir

For example:

    $ arm-none-eabi-gcc -mcpu=cortex-a55 -mfpu=auto -mfloat-abi=hard --print-multi-dir
    thumb/v8-a+simd/hard

    $ arm-none-eabi-gcc -mcpu=cortex-r5 -mfpu=auto -mfloat-abi=softfp --print-multi-dir
    thumb/v7+fp/softfp

    $ arm-none-eabi-gcc -mcpu=cortex-m0 -mfpu=auto -mfloat-abi=soft --print-multi-dir
    thumb/v6-m/nofp

* C Libraries usage *

This section only applies for arm-none-eabi targets.

GNU Toolchain 11.2-2022.02, for arm-none-eabi, is released with two
prebuilt C libraries based on newlib:
One is the standard newlib and the other is newlib-nano for code size.
To distinguish them, we rename the size optimized libraries as:

    libc.a --> libc_nano.a
    libg.a --> libg_nano.a

To use newlib-nano, users should provide additional gcc compile and link time
option:

    --specs=nano.specs

At compile time, a 'newlib.h' header file especially configured for newlib-nano
will be used if --specs=nano.specs is passed to the compiler.

nano.specs also handles two additional gcc libraries: libstdc++_nano.a and
libsupc++_nano.a, which are optimized for code size.

For example:

    $ arm-none-eabi-gcc src.c --specs=nano.specs ${OTHER_OPTIONS}

This option can also work together with other specs options like:

    --specs=rdimon.specs

Please note that --specs=nano.specs is both a compiler and linker option. Be
sure to include in both compiler and linker options if compiling and linking
are separated.

** additional newlib-nano libraries usage

Newlib-nano is different from newlib in addition to the libraries' name.
Formatted input/output of floating-point number are implemented as weak symbol.
If you want to use %f, you have to pull in the symbol by explicitly specifying
"-u" command option.

    -u _scanf_float
    -u _printf_float

e.g. to output a float, the command line is like:

    $ arm-none-eabi-gcc --specs=nano.specs -u _printf_float ${OTHER_LINK_OPTIONS}

For more about the difference and usage, please refer the README.nano in the
source package.

Users can choose to use or not use semihosting by following instructions.
** semihosting
If you need semihosting, linking like:

    $ arm-none-eabi-gcc --specs=rdimon.specs ${OTHER_LINK_OPTIONS}

** non-semihosting/retarget
If you are using retarget, linking like:

    $ arm-none-eabi-gcc --specs=nosys.specs ${OTHER_LINK_OPTIONS}

* Linker scripts & startup code *

This section only applies for arm-none-eabi targets.

Latest update of linker scripts template and startup code is available on
https://developer.arm.com/tools-and-software/embedded/cmsis

* Samples *

This section only applies for arm-none-eabi targets.

Examples are available at:

    ${install_dir}/share/gcc-arm-none-eabi/samples

Read readme.txt under it for further information.

* GDB Server for CMSIS-DAP based hardware debugger *

This section only applies for arm-none-eabi targets.

CMSIS-DAP is the interface firmware for a Debug Unit that connects
the Debug Port to USB.  More detailed information can be found at
http://www.keil.com/support/man/docs/dapdebug/.

A software GDB server is required for GDB to communicate with CMSIS-DAP based
hardware debugger.  The pyOCD is an implementation of such GDB server that is
written in Python and under Apache License.

For those who are using this toolchain and have board with CMSIS-DAP based
debugger, the pyOCD is our recommended gdb server.  More information can be
found at https://github.com/pyocd/pyOCD.