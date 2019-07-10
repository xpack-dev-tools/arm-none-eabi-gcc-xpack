# GNU MCU Eclipse ARM Embedded GCC - the build scripts

These are the scripts and additional files required to build the 
[GNU MCU Eclipse ARM Embedded GCC](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc).

## Prerequisites

The prerequisites are common to all binary builds. Please follow the 
instructions in the separate 
[Prerequisites for building binaries](https://gnu-mcu-eclipse.github.io/developer/build-binaries-prerequisites-xbb/) 
page and return when ready.

## Download the build scripts repo

The build script is available from GitHub and can be 
[viewed online](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-build/blob/master/scripts/build.sh).

To download it, clone the 
[gnu-mcu-eclipse/arm-none-eabi-gcc-build](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-build) 
Git repo, including submodules. 

```console
$ curl -L https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-build/raw/master/scripts/git-clone.sh | bash
```

which issues the following two commands:

```console
$ rm -rf ~/Downloads/arm-none-eabi-gcc-build.git
$ git clone --recurse-submodules https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-build.git \
  ~/Downloads/arm-none-eabi-gcc-build.git
```

## Check for newer submodule

The script uses a submodule helper. If you cloned the repo previously, 
with SourceTree, check if there are any newer commits for the submodule.

## Check the script

The script creates a temporary build `Work/arm-none-eabi-gcc-${version}` 
folder in the user home. Although not recommended, if for any reasons you 
need to change this, you can redefine `WORK_FOLDER_PATH` variable before 
invoking the script.

There are many other settings that can be redefined via
environment variables. If necessary,
place them in a file and pass it via `--env-file`. This file is
either passed to Docker or sourced to shell. The Docker syntax 
**is not** identical to shell, so some files may
not be accepted by bash.

## Preload the Docker images

Docker does not require to explicitly download new images, but does this 
automatically at first use.

However, since the images used for this build are relatively large, it is 
recommended to load them explicitly before starting the build:

```console
$ bash ~/Downloads/arm-none-eabi-gcc-build.git/scripts/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ilegeul/centos      6-xbb-v2.1          3644716694e8        2 weeks ago         2.99GB
ilegeul/centos32    6-xbb-v2.1          921d03805e50        2 weeks ago         2.91GB
hello-world         latest              f2a91732366c        2 months ago        1.85kB
```

## Remove unused Docker space

This is mostly useful after failed builds, during development, when
dangling images may be left by Docker.

To remove unused files:

```console
$ docker system prune --force
```

## Update git repos

The GNU MCU Eclipse ARM Embedded GCC distribution follows the official 
[ARM](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm) 
distributions, and it is planned to make a new release after each future 
ARM release.

Currently the build procedure uses the _Source Invariant_ archive and 
the configure options are the same as in the ARM build scripts.

## Prepare release

To prepare a new release:

- download the new _Source Invariant_ archive
- copy/paste the files and override the `arm-gcc-original-scripts.git` files 
  (except the PDF);
- commit with a message like **8-2018-q4-major**; also add a tag;
- check differences from the previous version;
- determine the GCC version (like `7.2.1`) and update the `scripts/VERSION` 
  file; the format is `7.2.1-1.1`. The fourth digit is the number of the 
  ARM release of the same GCC version, and the fifth digit is the GNU MCU 
  Eclipse release number of this version.
- add a new set of definitions in the `scripts/container-build.sh`, with 
  the versions of various components;
- if newer libraries are used, check if they are available from the local git
  cache project.

## Update CHANGELOG.txt

Check `arm-none-eabi-gcc-build.git/CHANGELOG.txt` and add the new release.

## Update the README-out.md

There should be no changes, but better check.

## Build

Although it is perfectly possible to build all binaries in a single step on 
a macOS system, due to Docker specifics, it is faster to build the GNU/Linux 
and Windows binaries on a GNU/Linux system and the macOS binary separately.

### Build the GNU/Linux and Windows binaries

The current platform for GNU/Linux and Windows production builds is an 
Ubuntu 18 LTS VirtualBox image running on a macMini with 16 GB of RAM 
and a fast SSD.

If the virtual machine runs on a macOS, to be sure it does not go
to sleep, run a `caffeinate bash`.

Before starting a multi-platform build, check if Docker is started:

```console
$ docker info
```

To build both the 32/64-bit Windows and GNU/Linux versions, use `--all`; to 
build selectively, use `--linux64 --win64` or `--linux32 --win32` (GNU/Linux 
can be built alone; Windows also requires the GNU/Linux build).

```console
$ sudo rm -rf "${HOME}/Work"/arm-none-eabi-gcc-*
$ bash ~/Downloads/arm-none-eabi-gcc-build.git/scripts/build.sh --all
```

Several hours later, the output of the build script is a set of 4 files and 
their SHA signatures, created in the `deploy` folder:

```console
$ ls -l deploy
total 350108
-rw-r--r-- 1 ilg ilg  61981364 Apr  1 08:27 gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-centos32.tar.xz
-rw-r--r-- 1 ilg ilg       140 Apr  1 08:27 gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-centos32.tar.xz.sha
-rw-r--r-- 1 ilg ilg  61144048 Apr  1 08:19 gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-centos64.tar.xz
-rw-r--r-- 1 ilg ilg       140 Apr  1 08:19 gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-centos64.tar.xz.sha
-rw-r--r-- 1 ilg ilg 112105889 Apr  1 08:29 gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-win32.zip
-rw-r--r-- 1 ilg ilg       134 Apr  1 08:29 gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-win32.zip.sha
-rw-r--r-- 1 ilg ilg 123181226 Apr  1 08:21 gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-win64.zip
-rw-r--r-- 1 ilg ilg       134 Apr  1 08:21 gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-win64.zip.sha
```

To copy the files from the build machine to the current development machine, 
open the `deploy` folder in a terminal and use `scp`:

```console
$ cd deploy
$ scp * ilg@ilg-mbp.local:Downloads/gme-binaries/arm
```

### Build the macOS binary

The current platform for macOS production builds is a macOS 10.10.5 VirtualBox 
image running on the same macMini with 16 GB of RAM and a fast SSD.

To build the latest macOS version, with the same timestamp as the previous 
build:

```console
$ sudo rm -rf "${HOME}/Work"/arm-none-eabi-gcc-*
$ caffeinate bash ~/Downloads/arm-none-eabi-gcc-build.git/scripts/build.sh --osx --date YYYYMMDD-HHMM
```

For consistency reasons, the date should be the same as the GNU/Linux and 
Windows builds.

Several hours later, the output of the build script is a compressed archive 
and its SHA signature, created in the `deploy` folder:

```console
$ ls -l deploy
total 216064
-rw-r--r--  1 ilg  staff  110620198 Jul 24 16:35 gnu-mcu-eclipse-arm-none-eabi-gcc-7.3.1-1.1-20180724-0637-macos.tgz
-rw-r--r--  1 ilg  staff        134 Jul 24 16:35 gnu-mcu-eclipse-arm-none-eabi-gcc-7.3.1-1.1-20180724-0637-macos.tgz.sha
```

To copy the files from the build machine to the current development machine, 
open the `deploy` folder in a terminal and use `scp`:

```console
$ cd deploy
$ scp * ilg@ilg-mbp.local:Downloads/gme-binaries/arm
```

## Subsequent runs

### Separate platform specific builds

Instead of `--all`, you can use any combination of:

```
--win32 --win64 --linux32 --linux64
```

Please note that, due to the specifics of the GCC build process, the 
Windows build requires the corresponding GNU/Linux build, so `--win32` 
alone is equivalent to `--linux32 --win32` and `--win64` alone is 
equivalent to `--linux64 --win64`.

### clean

To remove most build files, use:

```console
$ bash ~/Downloads/arm-none-eabi-gcc-build.git/scripts/build.sh clean
```

To also remove the repository and the output files, use:

```console
$ bash ~/Downloads/arm-none-eabi-gcc-build.git/scripts/build.sh cleanall
```

For production builds it is recommended to completely remove the build folder.

### --develop

For performance reasons, the actual build folders are internal to each 
Docker run, and are not persistent. This gives the best speed, but has 
the disadvantage that interrupted builds cannot be resumed.

For development builds, it is possible to define the build folders in the 
host file system, and resume an interrupted build.

### --debug

For development builds, it is also possible to create everything 
with `-g -O0` and be able to run debug sessions.

### Interrupted builds

The Docker scripts run with root privileges. This is generally not a 
problem, since at the end of the script the output files are reassigned 
to the actual user.

However, for an interrupted build, this step is skipped, and files in 
the install folder will remain owned by root. Thus, before removing the 
build folder, it might be necessary to run a recursive `chown`.

## Install

The procedure to install GNU MCU Eclipse ARM Embedded GCC is platform 
specific, but relatively straight forward (a .zip archive on Windows, 
a compressed tar archive on macOS and GNU/Linux).

A portable method is to use [`xpm`](https://www.npmjs.com/package/xpm):

```console
$ xpm install --global @gnu-mcu-eclipse/arm-none-eabi-gcc
```

More details are available on the 
[How to install the ARM toolchain?](https://gnu-mcu-eclipse.github.io/toolchain/arm/install/) 
page.

After install, the package should create a structure like this (only the 
first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/opt/gnu-mcu-eclipse/arm-none-eabi-gcc/8.2.1-1.1-20190102-1122 
/Users/ilg/opt/gnu-mcu-eclipse/arm-none-eabi-gcc/8.2.1-1.1-20190102-1122
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
│   ├── arm-none-eabi-gcc-8.2.1
│   ├── arm-none-eabi-gcc-ar
│   ├── arm-none-eabi-gcc-nm
│   ├── arm-none-eabi-gcc-ranlib
│   ├── arm-none-eabi-gcov
│   ├── arm-none-eabi-gcov-dump
│   ├── arm-none-eabi-gcov-tool
│   ├── arm-none-eabi-gdb
│   ├── arm-none-eabi-gdb-add-index
│   ├── arm-none-eabi-gdb-add-index-py
│   ├── arm-none-eabi-gdb-py
│   ├── arm-none-eabi-gprof
│   ├── arm-none-eabi-ld
│   ├── arm-none-eabi-ld.bfd
│   ├── arm-none-eabi-nm
│   ├── arm-none-eabi-objcopy
│   ├── arm-none-eabi-objdump
│   ├── arm-none-eabi-ranlib
│   ├── arm-none-eabi-readelf
│   ├── arm-none-eabi-size
│   ├── arm-none-eabi-strings
│   └── arm-none-eabi-strip
├── gnu-mcu-eclipse
│   ├── CHANGELOG.txt
│   ├── arm-readme.txt
│   ├── arm-release.txt
│   ├── licenses
│   ├── patches
│   └── scripts
├── include
│   └── gdb
├── lib
│   ├── gcc
│   ├── libcc1.0.so
│   └── libcc1.so -> libcc1.0.so
├── libexec
│   └── gcc
└── share
    ├── doc
    └── gcc-arm-none-eabi

19 directories, 37 files
```

No other files are installed in any system folders or other locations.

## Uninstall

The binaries are distributed as portable archives; thus they do not 
need to run a setup and do not require an uninstall.

## Test

A simple test is performed by the script at the end, by launching the 
executables to check if all shared/dynamic libraries are correctly used.

For a true test you need to first install the package and then run the 
program from the final location. For example on macOS the output should 
look like:

```console
$ /Users/ilg/Library/xPacks/\@gnu-mcu-eclipse/arm-none-eabi-gcc/7.2.1-1.1/.content/bin/arm-none-eabi-gcc --version
arm-none-eabi-gcc (GNU MCU Eclipse ARM Embedded GCC, 64-bit) 7.2.1 20170904 (release) [ARM/embedded-7-branch revision 255204]
```

## Pitfalls

### Parallel build

For various reasons, parallel builds for some components
fail with errors like 'vfork: insufficient resources'. Thus,
occasionally parallel build are disabled.

### Building GDB on macOS

GDB uses a complex and custom logic to unwind the stack when processing
exceptions; macOS also uses a custom logic to organize memory and process
exceptions; the result is that when compiling GDB with GCC on older macOS
systems (like 10.10), some details do not match and the resulting GDB 
crashes with an assertion on the first `set language` command (most 
probably many other commands).

The workaround was to compile GDB with Apple clang, which resulted in 
functional binaries, even on the old macOS 10.10.

## More build details

The build process is split into several scripts. The build starts on the 
host, with `build.sh`, which runs `container-build.sh` several times, 
once for each target, in one of the two docker containers. Both scripts 
include several other helper scripts. The entire process is quite complex, 
and an attempt to explain its functionality in a few words would not 
be realistic. Thus, the authoritative source of details remains the source 
code.
