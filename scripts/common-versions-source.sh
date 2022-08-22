# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the xPack build scripts. As the name implies,
# it should contain only functions and should be included with 'source'
# by the build scripts (both native and container).

# -----------------------------------------------------------------------------

function build_versions()
{
  APP_PREFIX_NANO="${INSTALL_FOLDER_PATH}/${APP_LC_NAME}-nano"

  # Don't use a comma since the regular expression
  # that processes this string in bfd/Makefile, silently fails and the
  # bfdver.h file remains empty.
  # XBB v3.1 update: newer tools expand the unicode and bfd/Makefile.in needs
  # a patch to avoid the comma separator.
  BRANDING="${DISTRO_NAME} ${APP_NAME} ${TARGET_MACHINE}"

  CFLAGS_OPTIMIZATIONS_FOR_TARGET="-ffunction-sections -fdata-sections -O2 -w"

  # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads
  # https://gcc.gnu.org/viewcvs/gcc/branches/ARM/

  # For the main GCC version, check gcc/BASE-VER.

  # ---------------------------------------------------------------------------
  # Defaults. Must be present.

  # Redefine to existing file names to enable patches.
  GCC_PATCH_FILE_NAME=""
  GDB_PATCH_FILE_NAME=""

  # ---------------------------------------------------------------------------

  # Redefine to "y" to create the LTO plugin links.
  if [ "${TARGET_PLATFORM}" == "darwin" ]
  then
    LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin.so"
    LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin.so"
  elif [ "${TARGET_PLATFORM}" == "linux" ]
  then
    LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin.so"
    LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin.so"
  elif [ "${TARGET_PLATFORM}" == "win32" ]
  then
    LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin.dll"
    LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin.dll"
  fi

  FIX_LTO_PLUGIN="y"

  NCURSES_DISABLE_WIDEC="y"

  # ---------------------------------------------------------------------------

  GCC_VERSION="$(echo "${RELEASE_VERSION}" | sed -e 's|-.*||')"
  GCC_VERSION_MAJOR=$(echo ${GCC_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    prepare_gcc_env "${CROSS_COMPILE_PREFIX}-"
  fi

  # In reverse chronological order.
  # Keep them in sync with the release manifest.txt file.
  # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads

  if [[ "${RELEASE_VERSION}" =~ 11\.3\.1-* ]]
  then
    # https://developer.arm.com/-/media/Files/downloads/gnu/11.3.rel1/manifest/arm-gnu-toolchain-arm-none-eabi-abe-manifest.txt
    (
      xbb_activate

      ARM_RELEASE="11.3.rel1"
      ARM_URL_BASE="https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_RELEASE}/src"

      # -------------------------------------------------------------------------
      # Build dependent libraries.

      # For better control, without it some components pick the lib packed
      # inside the archive.
      # https://zlib.net/fossils/
      build_zlib "1.2.12"

      # The classical GCC libraries.
      # https://gmplib.org/download/gmp/
      # Arm: In `gmp-h.in` search for `__GNU_MP_VERSION`.
      build_gmp "6.2.1"

      # http://www.mpfr.org/history.html
      # Arm: In `VERSION`.
      build_mpfr "3.1.6"

      # https://www.multiprecision.org/mpc/download.html
      # Arm: In `configure`, search for `VERSION=`.
      build_mpc "1.0.3"

      # https://sourceforge.net/projects/libisl/files/
      # Arm: In `configure`, search for `PACKAGE_VERSION=`.
      build_isl "0.15"

      # https://www.bytereef.org/mpdecimal/download.html
      build_libmpdec "2.5.1" # Used by Python

      # https://github.com/libexpat/libexpat/releases
      # Arm: In `configure`, search for `PACKAGE_VERSION=`.
      build_expat "2.2.5"

      # https://ftp.gnu.org/pub/gnu/libiconv/
      # Arm: In `configure`, search for `PACKAGE_VERSION=`.
      build_libiconv "1.15"

      # https://sourceforge.net/projects/lzmautils/files/
      build_xz "5.2.5"

      # Fails on mingw. 0.8.13 is deprecated. Not used anyway.
      # build_libelf "0.8.13"

      # http://ftp.gnu.org/pub/gnu/gettext/
      build_gettext "0.21"

      # https://www.python.org/ftp/python/
      # Requires `scripts/helper/extras/python/pyconfig-win-3.10.4.h` &
      # `python3-config.sh`
      PYTHON3_VERSION="3.10.4"
      WITH_GDB_PY3="y"

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        if [ "${WITH_GDB_PY3}" == "y" ]
        then
          # Shortcut, use the existing pyton.exe instead of building
          # if from sources. It also downloads the sources.
          download_python3_win "${PYTHON3_VERSION}"

          add_python3_win_syslibs
        fi
      else # linux or darwin
        # Used by ncurses. Fails on macOS.
        if [ "${TARGET_PLATFORM}" == "linux" ]
        then
          # https://github.com/telmich/gpm/tags
          # https://github.com/xpack-dev-tools/gpm/tags
          build_gpm "1.20.7-1"
        fi

        # https://ftp.gnu.org/gnu/ncurses/
        build_ncurses "6.3"

        # https://ftp.gnu.org/gnu/readline/
        build_readline "8.1"

        # https://sourceware.org/pub/bzip2/
        build_bzip2 "1.0.8"
        # https://github.com/libffi/libffi/releases
        build_libffi  "3.4.2"

        # We cannot rely on a python shared library in the system, even
        # the custom build from sources does not have one.

        if [ "${WITH_GDB_PY3}" == "y" ]
        then
          # Required by a Python 3 module.
          # https://www.sqlite.org/download.html
          build_sqlite  "3380200"

          # Replacement for the old libcrypt.so.1; required by Python 3.
          # https://github.com/besser82/libxcrypt/releases
          build_libxcrypt "4.4.28"

          # https://www.openssl.org/source/
          build_openssl "1.1.1n"

          build_python3 "${PYTHON3_VERSION}"

          add_python3_syslibs
        fi
      fi

      # -----------------------------------------------------------------------

      # The task descriptions are from the Arm build script.

      # Task [III-0] /$HOST_NATIVE/binutils/
      # Task [IV-1] /$HOST_MINGW/binutils/

      # Arm: abe-manifest.txt (release notes).
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: binutils-2_38-branch
      # Revision: 5c0b4ee406035917d0e50aa138194fab57ae6bf8
      # https://github.com/xpack-dev-tools/binutils-gdb/tags

      BINUTILS_VERSION="2.38"
      BINUTILS_TAG_NAME="binutils-${BINUTILS_VERSION}-arm-none-eabi-${ARM_RELEASE}"

      BINUTILS_SRC_FOLDER_NAME="binutils-gdb-${BINUTILS_TAG_NAME}"
      BINUTILS_ARCHIVE_NAME="${BINUTILS_TAG_NAME}.tar.gz"
      BINUTILS_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${BINUTILS_ARCHIVE_NAME}"

      build_cross_binutils
      # The nano requirement (copy_dir to libs) included above.

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://gcc.gnu.org/git/gcc.git
      # Branch: refs/vendors/ARM/heads/arm-11
      # Revision: 4249a65c814287af667aa78789436d3fc618e80a

      # GCC_VERSION computer from RELEASE_VERSION
      GCC_SRC_FOLDER_NAME="gcc"
      GCC_ARCHIVE_NAME="gcc-arm-none-eabi-${ARM_RELEASE}.tar.xz"
      GCC_ARCHIVE_URL="${ARM_URL_BASE}/gcc.tar.xz"

      GCC_PATCH_FILE_NAME="gcc-${GCC_VERSION}.patch.diff"
      GCC_MULTILIB_LIST="aprofile,rmprofile"

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then

        # Task [III-1] /$HOST_NATIVE/gcc-first/
        build_cross_gcc_first

        # Arm: release notes.
        # http://www.sourceware.org/newlib/
        # Repository: git://sourceware.org/git/newlib-cygwin.git
        # Revision: bfee9c6ab0c3c9a5742e84509d01ec6472aa62c4

        NEWLIB_VERSION="4.1.0"
        NEWLIB_SRC_FOLDER_NAME="newlib-cygwin"
        NEWLIB_ARCHIVE_NAME="newlib-arm-none-eabi-${ARM_RELEASE}.tar.xz"
        NEWLIB_ARCHIVE_URL="${ARM_URL_BASE}/newlib-cygwin.tar.xz"

        # Task [III-2] /$HOST_NATIVE/newlib/
        build_cross_newlib ""

        # Task [III-4] /$HOST_NATIVE/gcc-final/
        build_cross_gcc_final ""

        # Once again, for the -nano variant.
        # Task [III-3] /$HOST_NATIVE/newlib-nano/
        build_cross_newlib "-nano"

        # Task [III-5] /$HOST_NATIVE/gcc-size-libstdcxx/
        build_cross_gcc_final "-nano"

      else

        # Task [IV-2] /$HOST_MINGW/copy_libs/
        copy_cross_linux_libs

        # Task [IV-3] /$HOST_MINGW/gcc-final/
        build_cross_gcc_final ""

      fi

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: gdb-12-branch
      # Revision: 7f70cce769c1eced62012b0529907ea957cb9c55

      # https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/gdb-11-arm-none-eabi-11.2-2022.02.tar.gz

      # From `gdb/version.in`
      GDB_VERSION="12.1"
      GDB_TAG_NAME="gdb-12-arm-none-eabi-${ARM_RELEASE}"
      GDB_SRC_FOLDER_NAME="binutils-gdb-${GDB_TAG_NAME}"
      GDB_ARCHIVE_NAME="${GDB_TAG_NAME}.tar.gz"
      GDB_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${GDB_ARCHIVE_NAME}"

      # Mandatory, otherwise gdb-py3 is not relocatable.
      GDB_PATCH_FILE_NAME="gdb-${GDB_VERSION}.patch.diff"

      # Task [III-6] /$HOST_NATIVE/gdb/
      # Task [IV-4] /$HOST_MINGW/gdb/
      build_cross_gdb ""

      if [ "${WITH_GDB_PY3}" == "y" ]
      then
        build_cross_gdb "-py3"
      fi
    )
  elif [[ "${RELEASE_VERSION}" =~ 11\.2\.1-* ]]
  then
    # https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/manifest/gcc-arm-arm-none-eabi-abe-manifest.txt
    (
      xbb_activate

      ARM_RELEASE="11.2-2022.02"
      ARM_URL_BASE="https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_RELEASE}/src"

      # -------------------------------------------------------------------------
      # Build dependent libraries.

      # For better control, without it some components pick the lib packed
      # inside the archive.
      build_zlib "1.2.12" # "1.2.8"

      # The classical GCC libraries.
      # https://gmplib.org/download/gmp/
      # Arm: In `gmp-h.in` search for `__GNU_MP_VERSION`.
      build_gmp "6.2.1"

      # http://www.mpfr.org/history.html
      # Arm: In `VERSION`.
      build_mpfr "3.1.6"

      # https://www.multiprecision.org/mpc/download.html
      # Arm: In `configure`, search for `VERSION=`.
      build_mpc "1.0.3"

      # https://sourceforge.net/projects/libisl/files/
      # Arm: In `configure`, search for `PACKAGE_VERSION=`.
      build_isl "0.15"

      # https://www.bytereef.org/mpdecimal/download.html
      build_libmpdec "2.5.1" # "2.5.0" # Used by Python

      # https://github.com/libexpat/libexpat/releases
      # Arm: from release notes
      # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads-1
      build_expat "2.2.5" # "2.1.1"

      # https://ftp.gnu.org/pub/gnu/libiconv/
      # Arm: In `configure`, search for `PACKAGE_VERSION=`.
      build_libiconv "1.15"

      # https://sourceforge.net/projects/lzmautils/files/
      build_xz "5.2.5" # "5.2.3"

      # Fails on mingw. 0.8.13 is deprecated. Not used anyway.
      # build_libelf "0.8.13"

      # http://ftp.gnu.org/pub/gnu/gettext/
      build_gettext "0.21"

      # https://www.python.org/ftp/python/
      # Requires `scripts/helper/extras/python/pyconfig-win-3.10.4.h` &
      # `python3-config.sh`
      PYTHON3_VERSION="3.10.4"
      WITH_GDB_PY3="y"

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        if [ "${WITH_GDB_PY3}" == "y" ]
        then
          # Shortcut, use the existing pyton.exe instead of building
          # if from sources. It also downloads the sources.
          download_python3_win "${PYTHON3_VERSION}"

          add_python3_win_syslibs
        fi
      else # linux or darwin
        # Used by ncurses. Fails on macOS.
        if [ "${TARGET_PLATFORM}" == "linux" ]
        then
          # https://github.com/telmich/gpm/tags
          # https://github.com/xpack-dev-tools/gpm/tags
          build_gpm "1.20.7-1" # "1.20.7"
        fi

        # https://ftp.gnu.org/gnu/ncurses/
        build_ncurses "6.3" # "6.2"

        # https://ftp.gnu.org/gnu/readline/
        build_readline "8.1" # "8.0" # requires ncurses

        # https://sourceware.org/pub/bzip2/
        build_bzip2 "1.0.8"
        # https://github.com/libffi/libffi/releases
        build_libffi  "3.4.2" # "3.3"

        # We cannot rely on a python shared library in the system, even
        # the custom build from sources does not have one.

        if [ "${WITH_GDB_PY3}" == "y" ]
        then
          # Required by a Python 3 module.
          # https://www.sqlite.org/download.html
          build_sqlite  "3380200" # "3.32.3"

          # Replacement for the old libcrypt.so.1; required by Python 3.
          # https://github.com/besser82/libxcrypt/releases
          build_libxcrypt "4.4.28" # "4.4.17"

          # https://www.openssl.org/source/
          build_openssl "1.1.1n" # "1.1.1l" # "1.1.1h"

          build_python3 "${PYTHON3_VERSION}"

          add_python3_syslibs
        fi
      fi

      # -----------------------------------------------------------------------

      # The task descriptions are from the Arm build script.

      # Task [III-0] /$HOST_NATIVE/binutils/
      # Task [IV-1] /$HOST_MINGW/binutils/

      # Arm: release notes.
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: binutils-2_37-branch
      # Revision: 5f62caec8175cf80a29f2bcab2c5077cbfae8c89
      # https://github.com/xpack-dev-tools/binutils-gdb/tags

      BINUTILS_VERSION="2.37"
      BINUTILS_TAG_NAME="binutils-${BINUTILS_VERSION}-arm-none-eabi-${ARM_RELEASE}"

      BINUTILS_SRC_FOLDER_NAME="binutils-gdb-${BINUTILS_TAG_NAME}"
      BINUTILS_ARCHIVE_NAME="${BINUTILS_TAG_NAME}.tar.gz"
      BINUTILS_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${BINUTILS_ARCHIVE_NAME}"

      build_cross_binutils
      # The nano requirement (copy_dir to libs) included above.

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://gcc.gnu.org/git/gcc.git
      # Branch: refs/vendors/ARM/heads/arm-11
      # Revision:028202d8ad150f23fcccd4d923c96aff4c2607cf

      # GCC_VERSION computer from RELEASE_VERSION
      GCC_SRC_FOLDER_NAME="gcc"
      GCC_ARCHIVE_NAME="gcc-arm-none-eabi-${ARM_RELEASE}.tar.xz"
      GCC_ARCHIVE_URL="${ARM_URL_BASE}/gcc.tar.xz"

      GCC_PATCH_FILE_NAME="gcc-${GCC_VERSION}.patch.diff"
      GCC_MULTILIB_LIST="aprofile,rmprofile"

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then

        # Task [III-1] /$HOST_NATIVE/gcc-first/
        build_cross_gcc_first

        # Arm: release notes.
        # Repository: git://sourceware.org/git/newlib-cygwin.git
        # Revision: 2a3a03972b35377aef8d3d52d873ac3b8fcc512c

        NEWLIB_VERSION="4.1.0"
        NEWLIB_SRC_FOLDER_NAME="newlib-cygwin"
        NEWLIB_ARCHIVE_NAME="newlib-arm-none-eabi-${ARM_RELEASE}.tar.xz"
        NEWLIB_ARCHIVE_URL="${ARM_URL_BASE}/newlib-cygwin.tar.xz"

        # Task [III-2] /$HOST_NATIVE/newlib/
        build_cross_newlib ""

        # Task [III-4] /$HOST_NATIVE/gcc-final/
        build_cross_gcc_final ""

        # Once again, for the -nano variant.
        # Task [III-3] /$HOST_NATIVE/newlib-nano/
        build_cross_newlib "-nano"

        # Task [III-5] /$HOST_NATIVE/gcc-size-libstdcxx/
        build_cross_gcc_final "-nano"

      else

        # Task [IV-2] /$HOST_MINGW/copy_libs/
        copy_cross_linux_libs

        # Task [IV-3] /$HOST_MINGW/gcc-final/
        build_cross_gcc_final ""

      fi

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: gdb-11-branch
      # Revision: a10d1f2c33a9a329f3a3006e07cfe872a7cc965b

      # https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/gdb-11-arm-none-eabi-11.2-2022.02.tar.gz

      # From `gdb/version.in`
      GDB_VERSION="11.2"
      GDB_SRC_FOLDER_NAME="binutils-gdb-gdb-11-arm-none-eabi-${ARM_RELEASE}"
      GDB_ARCHIVE_NAME="gdb-11-arm-none-eabi-${ARM_RELEASE}.tar.gz"
      GDB_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${GDB_ARCHIVE_NAME}"

      # Mandatory, otherwise gdb-py3 is not relocatable.
      GDB_PATCH_FILE_NAME="gdb-${GDB_VERSION}.patch.diff"

      # Task [III-6] /$HOST_NATIVE/gdb/
      # Task [IV-4] /$HOST_MINGW/gdb/
      build_cross_gdb ""

      if [ "${WITH_GDB_PY3}" == "y" ]
      then
        build_cross_gdb "-py3"
      fi
    )

  else
    echo "Unsupported version ${RELEASE_VERSION}."
    exit 1
  fi

  # ---------------------------------------------------------------------------

  # Task [III-7] /$HOST_NATIVE/build-manual
  # Nope, the build process is different.

  # Task [III-8] /$HOST_NATIVE/pretidy/
  # Task [IV-5] /$HOST_MINGW/pretidy/
  tidy_up

  # Task [III-9] /$HOST_NATIVE/strip_host_objects/
  # Task [IV-6] /$HOST_MINGW/strip_host_objects/

  # strip_binaries # In common code.

  # `prepare_app_folder_libraries` must be done after gcc 2 make install,
  # otherwise some wrong links are created in libexec.
  # Must also be done after strip binaries, since strip after patchelf
  # damages the binaries.

  if [ "${TARGET_PLATFORM}" != "win32" ]
  then
    # Task [III-10] /$HOST_NATIVE/strip_target_objects/
    strip_libs
  fi

  final_tunings

  # Task [IV-7] /$HOST_MINGW/installation/
  # Nope, no setup.exe.

  # Task [III-11] /$HOST_NATIVE/package_tbz2/
  # Task [IV-8] /Package toolchain in zip format/
  # See create_archive below.

  # ---------------------------------------------------------------------------
}

# -----------------------------------------------------------------------------
