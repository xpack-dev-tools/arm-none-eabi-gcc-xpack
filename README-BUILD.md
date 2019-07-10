# How to build the xPack GNU ARM Embedded GCC?

## Introduction

This project includes the scripts and additional files required to 
build and publish the
[xPack GNU ARM Embedded GCC](https://xpack.github.io/qemu-arm/) binaries.

The build scripts use the
[xPack Build Box (XBB)](https://github.com/xpack/xpack-build-box), 
a set of elaborate build environments based on GCC 7.4 (Docker containers
for GNU/Linux and Windows or a custom folder for MacOS).

These are the scripts and additional files required to build the 
[xPack GNU ARM Embedded GCC](https://github.com/xpack-dev-tools/arm-none-eabi-gcc).

## Repository URLs

The build scripts use ARM archives; occasionally, to avoid bugs, original
repositories are used:

- `git://sourceware.org/git/binutils-gdb.git`

## Download the build scripts repo

The build scripts are available in the `scripts` folder of the 
[`xpack-dev-tools/arm-none-eabi-gcc-xpack`](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack) 
Git repo.

To download them, the following shortcut is available: 

```console
$ curl -L https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/raw/xpack/scripts/git-clone.sh | bash
```

This small script issues the following two commands:

```console
$ rm -rf ~/Downloads/arm-none-eabi-gcc-xpack.git
$ git clone --recurse-submodules https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack.git \
  ~/Downloads/arm-none-eabi-gcc-xpack.git
```

> Note: the repository uses submodules; for a successful build it is 
> mandatory to recurse the submodules.

## The `Work` folder

The script creates a temporary build `Work/qemu-arm-${version}` folder in 
the user home. Although not recommended, if for any reasons you need to 
change the location of the `Work` folder, 
you can redefine `WORK_FOLDER_PATH` variable before invoking the script.

## Customizations

There are many other settings that can be redefined via
environment variables. If necessary,
place them in a file and pass it via `--env-file`. This file is
either passed to Docker or sourced to shell. The Docker syntax 
**is not** identical to shell, so some files may
not be accepted by bash.

### Prerequisites

The prerequisites are common to all binary builds. Please follow the 
instructions from the separate 
[Prerequisites for building xPack binaries](https://xpack.github.io/xbb/prerequisites/) 
page and return when ready.

## Update git repos

The xPack GNU ARM Embedded GCC distribution follows the official 
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

### Update `README.md`

If necessary, update the main `README.md` with informations related to the
build. Information related to the new version should not be included here,
but in the version specific file (below).

### Create `README-<version>.md`

In the `scripts` folder create a copy of the previous one and update the
Git commit and possible other details.

## Update `CHANGELOG.md`

Check `CHANGELOG.md` and add the new release.

## Build

Although it is perfectly possible to build all binaries in a single step 
on a macOS system, due to Docker specifics, it is faster to build the 
GNU/Linux and Windows binaries on a GNU/Linux system and the macOS binary 
separately.

### Build the GNU/Linux and Windows binaries

The current platform for GNU/Linux and Windows production builds is an 
Ubuntu Server 18 LTS, running on an Intel NUC8i7BEH mini PC with 32 GB of RAM 
and 512 GB of fast M.2 SSD.

```console
$ ssh ilg-xbb-linux.local
```

Before starting a multi-platform build, check if Docker is started:

```console
$ docker info
```

Before running a build for the first time, it is recommended to preload the
docker images.

```console
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY TAG IMAGE ID CREATED SIZE
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ilegeul/centos32    6-xbb-v2.2          956eb2963946        5 weeks ago         3.03GB
ilegeul/centos      6-xbb-v2.2          6b1234f2ac44        5 weeks ago         3.12GB
hello-world         latest              fce289e99eb9        5 months ago        1.84kB
```

It is also recommended to Remove unused Docker space. This is mostly useful 
after failed builds, during development, when dangling images may be left 
by Docker.

To remove unused files:

```console
$ docker system prune --force
```

To download the build scripts:

```console
$ curl -L https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/raw/xpack/scripts/git-clone.sh | bash
```

To build both the 32/64-bit Windows and GNU/Linux versions, use `--all`; to 
build selectively, use `--linux64 --win64` or `--linux32 --win32` (GNU/Linux 
can be built alone; Windows also requires the GNU/Linux build).

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```console
$ screen -S arm

$ sudo rm -rf ~/Work/arm-none-eabi-gcc-*
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh --all
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r arm`; to kill the session use `Ctrl-a` `Ctrl-\` and confirm.

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

To copy the files from the build machine to the current development 
machine, either use NFS to mount the entire folder, or open the `deploy` 
folder in a terminal and use `scp`:

```console
$ cd ~/Work/arm-none-eabi-gcc-*/deploy
$ scp * ilg@ilg-mbp.local:Downloads/xpack-binaries/arm
```

### Build the macOS binary

The current platform for macOS production builds is a macOS 10.10.5 
VirtualBox image running on the same macMini with 16 GB of RAM and a 
fast SSD.

To build the latest macOS version:

```console
$ sudo rm -rf ~/Work/arm-none-eabi-gcc-*
$ caffeinate bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh --osx
```

Several hours later, the output of the build script is a compressed archive 
and its SHA signature, created in the `deploy` folder:

```console
$ ls -l deploy
total 216064
-rw-r--r--  1 ilg  staff  110620198 Jul 24 16:35 gnu-mcu-eclipse-arm-none-eabi-gcc-7.3.1-1.1-20180724-0637-macos.tgz
-rw-r--r--  1 ilg  staff        134 Jul 24 16:35 gnu-mcu-eclipse-arm-none-eabi-gcc-7.3.1-1.1-20180724-0637-macos.tgz.sha
```

To copy the files from the build machine to the current development 
machine, either use NFS to mount the entire folder, or open the `deploy` 
folder in a terminal and use `scp`:

```console
$ cd ~/Work/arm-none-eabi-gcc-*/deploy
$ scp * ilg@ilg-mbp.local:Downloads/xpack-binaries/arm
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
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh clean
```

To also remove the repository and the output files, use:

```console
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh cleanall
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

The procedure to install xPack GNU ARM Embedded GCC is platform 
specific, but relatively straight forward (a .zip archive on Windows, 
a compressed tar archive on macOS and GNU/Linux).

A portable method is to use [`xpm`](https://www.npmjs.com/package/xpm):

```console
$ xpm install --global @xpack-dev-tools/arm-none-eabi-gcc
```

More details are available on the 
[How to install the ARM toolchain?](https://xpack.github.io/arm-none-eabi-gcc/install/) 
page.

After install, the package should create a structure like this (only the 
first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/opt/xPacks/arm-none-eabi-gcc/8.2.1-1.1 
/Users/ilg/opt/gnu-mcu-eclipse/arm-none-eabi-gcc/8.2.1-1.1
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
├── distro-info
│   ├── CHANGELOG.md
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
$ /Users/ilg/Library/xPacks/\@xpack-dev-tools/arm-none-eabi-gcc/7.2.1-1.1/.content/bin/arm-none-eabi-gcc --version
arm-none-eabi-gcc (xPack GNU ARM Embedded GCC, 64-bit) 7.2.1 20170904 (release) [ARM/embedded-7-branch revision 255204]
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
