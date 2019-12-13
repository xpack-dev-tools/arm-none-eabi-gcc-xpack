# How to build the xPack GNU Arm Embedded GCC?

## Introduction

This separate file documents how to build the **xPack GNU Arm Embedded GCC**
binaries that run on Arm GNU/Linux systems.

For the moment building Arm binaries is still experimental, and uses
native builds.

## Supported architectures

The supported Arm architectures are:

- `armhf` for 32-bit devices
- `arm64` for 64-bit devices

As development environments for building Arm distribution binaries, 
the **Ubuntu 16.04.6
LTS (xenial)** was selected, as it was the first major release that supported
64-bit Arm devices, and is old enough to support most of the existing
boards.

For personal use, you can run the script on more recent versions of Ubuntu.

## Prerequisites

The build environment can be either a physical board or a virtual
machine running on QEMU.

### Physical boards

For successful builds, the build system should have more than 1 GB of RAM,
preferably 4 GB or more (if you can get such a board!) to be able to run
parallel builds and speed the process.

The details of installing Ubuntu 16.04 LTS on the board are beyond the
scope of this project.

For example, for Raspberry Pi you can install the official Ubuntu Server:

- https://ubuntu.com/download/raspberry-pi

For other boards you can use the `hwe-netboot` folder for the 64-bit and
`hwe-generic-lpae` for the 32-bit, available from Ubuntu download server:

- http://ports.ubuntu.com/ubuntu-ports/dists/xenial-updates/main/installer-arm64/current/images/
- http://ports.ubuntu.com/ubuntu-ports/dists/xenial-updates/main/installer-armhf/current/images/

### QEMU virtual machine

For experimenting, it is also possible to run the script on a virtual
machine, but be prepared to wait more than one day for a multilib run.

A detailed page on how to run Ubuntu 16 on QEMU is available
in the separate
[xpack/arm-linux-files](https://github.com/xpack/arm-linux-files) project.

### Ubuntu packages

Once you have a functional Ubuntu base system, install the dependencies.

The main tool needed while building the binaries is the GCC 7.4 compiler,
which, for Ubuntu 16, is available via the special repositories:

```console
$ sudo apt-get install --yes software-properties-common
$ sudo add-apt-repository --yes ppa:ubuntu-toolchain-r/test
$ sudo apt update --yes
$ sudo apt upgrade --yes

$ sudo apt install --yes \
git \
curl \
make \
pkg-config \
m4 \
gawk \
autoconf automake \
libtool libtool-bin \
gettext \
bison \
texinfo \
patchelf \
dos2unix \
flex \
perl \
cmake \
python libpython-dev \
python3 libpython3-dev \
g++-7

$ sudo apt install --yes \
texlive \
texlive-generic-recommended \
texlive-extra-utils
```

To test if the compiler was correcty installed:

```console
$ gcc-7 --version
gcc-7 (Ubuntu 7.4.0-1ubuntu1~16.04~ppa1) 7.4.0
```

With this setup, the versions of the other major tools are:

```console
$ git --version
git version 2.7.4
$ curl --version
curl 7.47.0 ...
$ make --version
GNU Make 4.1
$ pkg-config --version
0.29.1
$ m4 --version
m4 (GNU M4) 1.4.17
$ gawk --version
GNU Awk 4.1.3, API: 1.1 (GNU MPFR 3.1.4, GNU MP 6.1.0)
$ automake --version
automake (GNU automake) 1.15
$ libtool --version
libtool (GNU libtool) 2.4.6
$ gettext --version
gettext (GNU gettext-runtime) 0.19.7
$ bison --version
bison (GNU Bison) 3.0.4
$ makeinfo --version
texi2any (GNU texinfo) 6.1
$ patchelf --version
patchelf 0.9
$ dos2unix --version
dos2unix 6.0.4 (2013-12-30)
$ flex --version
flex 2.6.0
$ perl --version
This is perl 5, version 22, subversion 1 (v5.22.1) built ...
$ cmake --version
cmake version 3.5.1
$ python2 --version
Python 2.7.12
$ python3 --version
Python 3.5.2
```

## Download the build scripts

The build scripts are available in the `scripts` folder of the
[`xpack-dev-tools/arm-none-eabi-gcc-xpack`](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack)
Git repo.

To download them, the following shortcut is available:

```console
$ curl -L https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/raw/xpack/scripts/git-clone.sh | bash
```

There is also a shortcut to download the `xpack-develop` branch:

```console
$ curl -L https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/raw/xpack/scripts/git-clone-develop.sh | bash
```

For more details please read the `README-BUILD.md` file.

## The `Work` folder

The script creates a temporary build `Work/arm-none-eabi-gcc-${version}`
folder in the user home. Although not recommended, if for any reasons
you need to change the location of the `Work` folder,
you can redefine `WORK_FOLDER_PATH` variable before invoking the script.

## Customizations

There are many other settings that can be redefined via
environment variables.

## How to build

The native build scripts can be executed both on 64-bit and 32-bit systems,
and will generate the binaries for the same architecture as the host,
so two host systems are required for both 32/64-bit binaries.

### Build the GNU/Linux and Windows binaries

If the build machine is remote, connect to it. For example to
connect to a QEMU virtual machine running on `ilg-xbb-linux` use the
QEMU forward port defined when starting the machine:

```console
$ ssh ilg@ilg-xbb-linux.local -p 30064
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```console
$ screen -S arm

$ sudo rm -rf ~/Work/arm-none-eabi-gcc-*
$ /usr/bin/time bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build-native.sh --jobs 4
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r arm`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

Many hours later, the output of the build script is a set of 2 files and
their SHA signatures, created in the `deploy` folder:

```console
$ ls -l deploy
total 487380
-rw-r--r-- 1 ilg ilg 115361011 Jul 26 11:57 xpack-arm-none-eabi-gcc-9.2.1-1.2-linux-arm64.tgz
-rw-r--r-- 1 ilg ilg       114 Jul 26 11:57 xpack-arm-none-eabi-gcc-9.2.1-1.2-linux-arm64.tgz.sha
```

The `/usr/bin/time` is useful to get a short report on the resources used
by the build, like time and memory.

```console
60856.18user 10517.07system 7:34:51elapsed 261%CPU (0avgtext+0avgdata 681076maxresident)k
189520inputs+15266392outputs (531major+320166700minor)pagefaults 0swaps
```

## Subsequent runs

The script accepts several command line options and can be resumed 
if interrupted.

### --disable-multilib

For development bulds, the very lengthy builds for the multiple libraries
can be disabled.

### --jobs

By default, the build steps use a single job at a time, but for
recent CPUs with multiple cores it is possible to run multiple jobs
in parallel.

The setting applies to all steps.

Warning: Parallel builds require significant system resources and occasionally
may crash the build.

### --debug

For development builds, it is also possible to create everything
with `-g -O0` and be able to run debug sessions.

## Test

A simple test is performed by the script at the end, by launching the
executables to check if all shared/dynamic libraries are correctly used.

For a true test you need to unpack the archive in a temporary location
(like `~/Downloads`) and then run the
program from there. 

```console
$ /Users/ilg/Downloads/xPacks/arm-none-eabi-gcc/9.2.1-1.2/bin/arm-none-eabi-gcc --version
arm-none-eabi-gcc (xPack GNU Arm Embedded GCC, 64-bit) 9.2.1 20170904 (release) [ARM/embedded-7-branch revision 255204]
```

## Installed folders

After install, the package should create a structure like this (only the
first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/Library/xPacks/\@xpack-dev-tools/arm-none-eabi-gcc/9.2.1-1.2/.content/
/Users/ilg/Library/xPacks/\@xpack-dev-tools/arm-none-eabi-gcc/9.2.1-1.2/.content/
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
│   ├── arm-none-eabi-gcc-9.2.1
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

## Files cache

The build scripts use a local cache such that files are downloaded only
during the first run, later runs being able to use the cached files.

However, occasionally some servers may not be available, and the builds
may fail.

The workaround is to manually download the files from an alternate
location (like
https://github.com/xpack-dev-tools/files-cache/tree/master/libs),
place them in the XBB cache (`Work/cache`) and restart the build.

## Pitfalls

### Parallel builds

For various reasons, in some environments, parallel builds for
some components fail. Reduce the number of parallel jobs until
the build passes.

