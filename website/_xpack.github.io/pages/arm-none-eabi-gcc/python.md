---

title: GDB with Python support
permalink: /dev-tools/arm-none-eabi-gcc/python/

summary: "Support for Python 2 and 3 is available in GDB."

comments: true
toc: false

date: 2020-01-28 19:18:00 +0200

---

## Overview

{% include note.html content="This page applies only to early
releases, which
required Python to be installed in the system; current releases
are standalone and include a Python runtime, so
these steps are no longer required." %}

Starting with GDB 7, support for
[extending GDB with Python scripting](https://sourceware.org/gdb/onlinedocs/gdb/Python.html)
was added to GDB.

The **xPack GNU Arm Embedded GCC** also supports this, by providing two
separate binaries:

- `arm-none-eabi-gdb-py` with Python 2 support
- `arm-none-eabi-gdb-py3` with Python 3 support

## Prerequisites

Due to some Python internals, when embedded in other applications,
the Python run-time remains tied to the version used during the build process.

With the current versions of XBB (v3.1), these versions are:

- **2.7**
- **3.7**

The immediate consequence of this characteristic is that in order for
`gdb-py` and `gdb-py3` to run properly, these exact versions of Python
must be available.

{% capture windows %}

Windows - TO BE ADDED

{% endcapture %}

{% capture macos %}

As of macOS 10.15, Apple provides Python 2.7 as part of the basic system
install.

```console
% python2 -c 'from distutils import sysconfig;print(sysconfig.PREFIX)'
/System/Library/Frameworks/Python.framework/Versions/2.7
```

However, it displays a warning:

```console
% python2

WARNING: Python 2.7 is not recommended.
This version is included in macOS for compatibility with legacy software.
Future versions of macOS will not include Python 2.7.
Instead, it is recommended that you transition to using 'python3' from within Terminal.

Python 2.7.16 (default, Dec 13 2019, 18:00:32)
```

Python 3 is not directly available, but may come packed with some
recent releases of the Command Line Tools.

```console
% python3 -c 'from distutils import sysconfig;print(sysconfig.PREFIX)'
/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.7
```

For consistent results, the GDB binaries were built agains the official
Python binaries, available from
[Python Releases for Mac OS X](https://www.python.org/downloads/mac-osx/):

- [Python 2.7.17](https://www.python.org/ftp/python/2.7.17/python-2.7.17-macosx10.9.pkg)
- [Python 3.7.6](https://www.python.org/ftp/python/3.7.6/python-3.7.6-macosx10.9.pkg)

For a seamless experience, **it is recommended to install exactly these
versions**.

If Python 2 is not installed in the default location
(`/Library/Frameworks/Python.framework/Versions/2.7`)
attempts to run `gdb-py` directly will fail:

```console
% arm-none-eabi-gdb-py
Could not find platform independent libraries <prefix>
Could not find platform dependent libraries <exec_prefix>
Consider setting $PYTHONHOME to <prefix>[:<exec_prefix>]
ImportError: No module named site
```

However, it is possible to use the Apple binaries, or any other binaries,
(like Homebrew), if GDB is informed about the location where Python is
installed, via the environment variable `PYTHONHOME`:

```console
% PYTHONHOME="$(python2 -c 'from distutils import sysconfig;print(sysconfig.PREFIX)')" arm-none-eabi-gdb-py --config
This GDB was configured as follows:
   configure --host=x86_64-apple-darwin14.5.0 --target=arm-none-eabi
             --with-auto-load-dir=$debugdir:$datadir/auto-load
             --with-auto-load-safe-path=$debugdir:$datadir/auto-load
             --with-expat
             --with-gdb-datadir=/Users/ilg/Work/arm-none-eabi-gcc-9.2.1-1.2/darwin-x64/install/arm-none-eabi-gcc/arm-none-eabi/share/gdb (relocatable)
             --with-jit-reader-dir=/Users/ilg/Work/arm-none-eabi-gcc-9.2.1-1.2/darwin-x64/install/arm-none-eabi-gcc/lib/gdb (relocatable)
             --without-libunwind-ia64
             --with-lzma
             --without-babeltrace
             --without-intel-pt
             --disable-libmcheck
             --with-mpfr
             --with-python=/Library/Frameworks/Python.framework/Versions/2.7
             --without-guile
             --disable-source-highlight
             --with-separate-debug-dir=/Users/ilg/Work/arm-none-eabi-gcc-9.2.1-1.2/darwin-x64/install/arm-none-eabi-gcc/lib/debug (relocatable)
             --with-system-gdbinit=/Users/ilg/Work/arm-none-eabi-gcc-9.2.1-1.2/darwin-x64/install/arm-none-eabi-gcc/arm-none-eabi/lib/gdbinit (relocatable)

("Relocatable" means the directory can be moved with the GDB installation
tree, and GDB will still find it.)
```

Similarly, if Python 3 is not installed in the default location
(`/Library/Frameworks/Python.framework/Versions/3.7`)
attempts to run `gdb-py3` directly will fail:

```console
% arm-none-eabi-gdb-py3
Could not find platform independent libraries <prefix>
Could not find platform dependent libraries <exec_prefix>
Consider setting $PYTHONHOME to <prefix>[:<exec_prefix>]
Fatal Python error: initfsencoding: unable to load the file system codec
ModuleNotFoundError: No module named 'encodings'

Current thread 0x0000000106239dc0 (most recent call first):
zsh: abort
```

If Python 3 is installed, setting `PYTHONHOME` to its location
allows `gdb-py3` to start properly:

```console
% PYTHONHOME="$(python3 -c 'from distutils import sysconfig;print(sysconfig.PREFIX)')" arm-none-eabi-gdb-py3 --config
This GDB was configured as follows:
   configure --host=x86_64-apple-darwin14.5.0 --target=arm-none-eabi
             --with-auto-load-dir=$debugdir:$datadir/auto-load
             --with-auto-load-safe-path=$debugdir:$datadir/auto-load
             --with-expat
             --with-gdb-datadir=/Users/ilg/Work/arm-none-eabi-gcc-9.2.1-1.2/darwin-x64/install/arm-none-eabi-gcc/arm-none-eabi/share/gdb (relocatable)
             --with-jit-reader-dir=/Users/ilg/Work/arm-none-eabi-gcc-9.2.1-1.2/darwin-x64/install/arm-none-eabi-gcc/lib/gdb (relocatable)
             --without-libunwind-ia64
             --with-lzma
             --without-babeltrace
             --without-intel-pt
             --disable-libmcheck
             --with-mpfr
             --with-python=/Library/Frameworks/Python.framework/Versions/3.7
             --without-guile
             --disable-source-highlight
             --with-separate-debug-dir=/Users/ilg/Work/arm-none-eabi-gcc-9.2.1-1.2/darwin-x64/install/arm-none-eabi-gcc/lib/debug (relocatable)
             --with-system-gdbinit=/Users/ilg/Work/arm-none-eabi-gcc-9.2.1-1.2/darwin-x64/install/arm-none-eabi-gcc/arm-none-eabi/lib/gdbinit (relocatable)

("Relocatable" means the directory can be moved with the GDB installation
tree, and GDB will still find it.)
```

The technical reason why the GDB binaries are tied to a given Python version is
that the Python run-time is packed as a versioned library named like
`libpython2.7.dylib`,
in other words with both major and minor numbers, which probably means that
versions with different minor numbers are not compatible. The reference to
this library can be circumvented by packing the library with the executable.

To make things even worse, each Python version expects to find a
versioned folder like `lib/python2.7` in the Python home folder, which
again probably means that the content is not compatible between versions
with different minor numbers.

{% endcapture %}

{% capture linux %}

Most modern distributions come with both Python 2 and 3 available as
native packages, but some come with versions different from 2.7 and 3.7.

For consistent results, the GDB binaries were built against the official
Python binaries, available from
[Python Source Releases](https://www.python.org/downloads/source/):

- [Python 2.7.17](https://www.python.org/ftp/python/2.7.17/Python-2.7.17.tgz)
- [Python 3.7.6](https://www.python.org/ftp/python/3.7.6/Python-3.7.6.tgz)

For a seamless experience, **it is recommended to install exactly these
versions**.

To compile Python 2 use the following commands:

```bash
python2_version="2.7.17"
mkdir -p "${HOME}/Downloads"
curl -L --fail -o "${HOME}/Downloads/Python-${python2_version}.tgz" \
https://www.python.org/ftp/python/${python2_version}/Python-${python2_version}.tgz

rm -rf "${HOME}/Work/Python-${python2_version}"
mkdir -p "${HOME}/Work"
cd "${HOME}/Work"
tar xzf "${HOME}/Downloads/Python-${python2_version}.tgz"

cd "${HOME}/Work/Python-${python2_version}"
bash ./configure --enable-unicode=ucs4
make

sudo make altinstall
```

To check where the new binaries were installed:

```console
$ which python2.7
/usr/local/bin/python2.7
```

To compile Python 3 use the following commands:

```bash
python3_version="3.7.6"
mkdir -p "${HOME}/Downloads"
curl -L --fail -o "${HOME}/Downloads/Python-${python3_version}.tgz" \
https://www.python.org/ftp/python/${python3_version}/Python-${python3_version}.tgz

rm -rf "${HOME}/Work/Python-${python3_version}"
mkdir -p "${HOME}/Work"
cd "${HOME}/Work"
tar xzf "${HOME}/Downloads/Python-${python3_version}.tgz"

cd "${HOME}/Work/Python-${python3_version}"
bash ./configure
make

sudo make altinstall
```

To check where the new binaries were installed:

```console
$ which python3.7
/usr/local/bin/python3.7
```

The technical reason why the GDB binaries are tied to a given Python version is
that the Python run-time is packed as a versioned library named like
`libpython2.7.so.1.0`,
in other words with both major and minor numbers, which probably means that
versions with different minor numbers are not compatible. The reference to
this library can be circumvented by packing the library with the executable.

To make things even worse, each Python version expects to find a
versioned folder like `lib/python2.7` in the Python home folder, which
again probably means that the content is not compatible between versions
with different minor numbers.

Debian & related distributions are particularly picky with embedded
Python applications, and attempts to run gdb-py usually end in:

```console
/home/ilg/Work/test-arm-none-eabi-gcc/xpack-arm-none-eabi-gcc-9.2.1-1.2/bin/arm-none-eabi-gdb-py --version
Traceback (most recent call last):
 File "/usr/lib/python2.7/site.py", line 554, in <module>
   main()
 File "/usr/lib/python2.7/site.py", line 536, in main
   known_paths = addusersitepackages(known_paths)
 File "/usr/lib/python2.7/site.py", line 272, in addusersitepackages
   user_site = getusersitepackages()
 File "/usr/lib/python2.7/site.py", line 247, in getusersitepackages
   user_base = getuserbase() # this will also set USER_BASE
 File "/usr/lib/python2.7/site.py", line 237, in getuserbase
   USER_BASE = get_config_var('userbase')
 File "/usr/lib/python2.7/sysconfig.py", line 587, in get_config_var
   return get_config_vars().get(name)
 File "/usr/lib/python2.7/sysconfig.py", line 533, in get_config_vars
   _init_posix(_CONFIG_VARS)
 File "/usr/lib/python2.7/sysconfig.py", line 417, in _init_posix
   from _sysconfigdata import build_time_vars
 File "/usr/lib/python2.7/_sysconfigdata.py", line 6, in <module>
   from _sysconfigdata_nd import *
ImportError: No module named _sysconfigdata_nd
```

Install Python 2.7 as instructed before, and gdb-py will start properly.

{% endcapture %}

{% include platform-tabs.html %}
