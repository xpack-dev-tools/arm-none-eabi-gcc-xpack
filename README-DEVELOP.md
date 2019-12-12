# Development info

## Prerequisites

For native builds, the validated environment is Ubuntu 16, also used
to build the Arm binaries.

### Ubuntu 16.04.6

The main tool needed while building the binaries is the GCC 7.4 compiler,
which, for Ubuntu 16, is available via the special repositories, so it is
not necessary to run the scripts to create the XBB folder.

```console
$ sudo apt-get install -y software-properties-common
$ sudo add-apt-repository ppa:ubuntu-toolchain-r/test
$ sudo apt update

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
python python3 \
g++-7

$ sudo apt install --yes \
libpython-dev \
libpython3-dev

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

Other versions are:

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

## How to use

### Download the build scripts

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

### Check if the remote development branch is up-to-date

Open the local copy of `arm-none-eabi-gcc-xpack.git` and check if the
development branch is
pushed to the remote, since the script will use it when `--develop` is passed.

### Native build

To build the binaries using the native environment, run the
`build-native.sh` script, with a number o parallel jobs that fits the machine:

```console
$ /usr/bin/time bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build-native.sh --jobs 4
```

The result is an archive in `${HOME}/Work/arm-none-eabi-gcc-<version>/deploy`
folder.
