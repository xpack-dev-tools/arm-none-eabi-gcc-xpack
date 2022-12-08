# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_application_versioned_components()
{
  # XBB_APPLICATION_PREFIX_NANO="${XBB_APPLICATION_INSTALL_FOLDER_PATH}-nano"
  XBB_APPLICATION_NANO_INSTALL_FOLDER_PATH="${XBB_APPLICATION_INSTALL_FOLDER_PATH}-nano"

  # Don't use a comma since the regular expression
  # that processes this string in bfd/Makefile, silently fails and the
  # bfdver.h file remains empty.
  # XBB v3.1 update: newer tools expand the unicode and bfd/Makefile.in needs
  # a patch to avoid the comma separator.
  XBB_BRANDING="${XBB_APPLICATION_DISTRO_NAME} ${XBB_APPLICATION_NAME} ${XBB_REQUESTED_TARGET_MACHINE}"

  XBB_CFLAGS_OPTIMIZATIONS_FOR_TARGET="-ffunction-sections -fdata-sections -O2 -w"

  # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads
  # https://gcc.gnu.org/viewcvs/gcc/branches/ARM/

  # For the main GCC version, check gcc/BASE-VER.

  # ---------------------------------------------------------------------------
  # Defaults. Must be present.

  # Redefine to existing file names to enable patches.
  XBB_GCC_PATCH_FILE_NAME=""
  XBB_GDB_PATCH_FILE_NAME=""

  # ---------------------------------------------------------------------------

  # Redefine to "y" to create the LTO plugin links.
  if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
  then
    XBB_LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin.so"
    XBB_LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin.so"
  elif [ "${XBB_HOST_PLATFORM}" == "linux" ]
  then
    XBB_LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin.so"
    XBB_LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin.so"
  elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
  then
    XBB_LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin.dll"
    XBB_LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin.dll"
  fi

  XBB_FIX_LTO_PLUGIN="y"

  XBB_NCURSES_DISABLE_WIDEC="y"

  XBB_WITH_GDB_PY3=""

  # ---------------------------------------------------------------------------

  XBB_GCC_VERSION="$(echo "${XBB_RELEASE_VERSION}" | sed -e 's|-.*||')"
  XBB_GCC_VERSION_MAJOR=$(echo ${XBB_GCC_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  # In reverse chronological order.
  # Keep them in sync with the release manifest.txt file.
  # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads

  if [[ "${XBB_RELEASE_VERSION}" =~ 11\.*\.*-* ]]
  then

    if [[ "${XBB_RELEASE_VERSION}" =~ 11\.3\.1-* ]]
    then
      # https://developer.arm.com/-/media/Files/downloads/gnu/11.3.rel1/manifest/arm-gnu-toolchain-arm-none-eabi-abe-manifest.txt

      XBB_ARM_RELEASE="11.3.rel1"
      XBB_ARM_URL_BASE="https://developer.arm.com/-/media/Files/downloads/gnu/${XBB_ARM_RELEASE}/src"

      # ---------------------------------------------------------------------

      # Arm: abe-manifest.txt (release notes).
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: binutils-2_38-branch
      # Revision: 5c0b4ee406035917d0e50aa138194fab57ae6bf8
      # https://github.com/xpack-dev-tools/binutils-gdb/tags

      XBB_BINUTILS_VERSION="2.38"
      XBB_BINUTILS_TAG_NAME="binutils-${XBB_BINUTILS_VERSION}-arm-none-eabi-${XBB_ARM_RELEASE}"

      XBB_BINUTILS_SRC_FOLDER_NAME="binutils-gdb-${XBB_BINUTILS_TAG_NAME}"
      XBB_BINUTILS_ARCHIVE_NAME="${XBB_BINUTILS_TAG_NAME}.tar.gz"
      XBB_BINUTILS_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${XBB_BINUTILS_ARCHIVE_NAME}"

      XBB_BINUTILS_PATCH_FILE_NAME="binutils-${XBB_BINUTILS_VERSION}.patch"

      # ---------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://gcc.gnu.org/git/gcc.git
      # Branch: refs/vendors/ARM/heads/arm-11
      # Revision: 4249a65c814287af667aa78789436d3fc618e80a

      # XBB_GCC_VERSION computer from XBB_RELEASE_VERSION
      XBB_GCC_SRC_FOLDER_NAME="gcc"
      XBB_GCC_ARCHIVE_NAME="gcc-arm-none-eabi-${XBB_ARM_RELEASE}.tar.xz"
      XBB_GCC_ARCHIVE_URL="${XBB_ARM_URL_BASE}/gcc.tar.xz"

      XBB_GCC_PATCH_FILE_NAME="gcc-${XBB_GCC_VERSION}-cross.patch.diff"
      XBB_GCC_MULTILIB_LIST="aprofile,rmprofile"

      # ---------------------------------------------------------------------

      # Arm: release notes.
      # http://www.sourceware.org/newlib/
      # Repository: git://sourceware.org/git/newlib-cygwin.git
      # Revision: bfee9c6ab0c3c9a5742e84509d01ec6472aa62c4

      XBB_NEWLIB_VERSION="4.1.0"
      XBB_NEWLIB_SRC_FOLDER_NAME="newlib-cygwin"
      XBB_NEWLIB_ARCHIVE_NAME="newlib-arm-none-eabi-${XBB_ARM_RELEASE}.tar.xz"
      XBB_NEWLIB_ARCHIVE_URL="${XBB_ARM_URL_BASE}/newlib-cygwin.tar.xz"

      # ---------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: gdb-12-branch
      # Revision: 7f70cce769c1eced62012b0529907ea957cb9c55

      # https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/gdb-11-arm-none-eabi-11.2-2022.02.tar.gz

      # From `gdb/version.in`
      XBB_GDB_VERSION="12.1"
      XBB_GDB_TAG_NAME="gdb-12-arm-none-eabi-${XBB_ARM_RELEASE}"

      XBB_GDB_SRC_FOLDER_NAME="binutils-gdb-${XBB_GDB_TAG_NAME}"
      XBB_GDB_ARCHIVE_NAME="${XBB_GDB_TAG_NAME}.tar.gz"
      XBB_GDB_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${XBB_GDB_ARCHIVE_NAME}"

      # Mandatory, otherwise gdb-py3 is not relocatable.
      XBB_GDB_PATCH_FILE_NAME="gdb-${XBB_GDB_VERSION}-cross.patch.diff"

    elif [[ "${XBB_RELEASE_VERSION}" =~ 11\.2\.1-* ]]
    then
      # https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/manifest/gcc-arm-arm-none-eabi-abe-manifest.txt
      XBB_ARM_RELEASE="11.2-2022.02"
      XBB_ARM_URL_BASE="https://developer.arm.com/-/media/Files/downloads/gnu/${XBB_ARM_RELEASE}/src"

      # ---------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: binutils-2_37-branch
      # Revision: 5f62caec8175cf80a29f2bcab2c5077cbfae8c89
      # https://github.com/xpack-dev-tools/binutils-gdb/tags

      XBB_BINUTILS_VERSION="2.37"

      # Tag in the local binutils fork.
      XBB_BINUTILS_TAG_NAME="binutils-${XBB_BINUTILS_VERSION}-arm-none-eabi-${XBB_ARM_RELEASE}"

      XBB_BINUTILS_SRC_FOLDER_NAME="binutils-gdb-${XBB_BINUTILS_TAG_NAME}"
      XBB_BINUTILS_ARCHIVE_NAME="${XBB_BINUTILS_TAG_NAME}.tar.gz"
      XBB_BINUTILS_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${XBB_BINUTILS_ARCHIVE_NAME}"

      # ---------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://gcc.gnu.org/git/gcc.git
      # Branch: refs/vendors/ARM/heads/arm-11
      # Revision:028202d8ad150f23fcccd4d923c96aff4c2607cf

      # XBB_GCC_VERSION computer from XBB_RELEASE_VERSION
      XBB_GCC_SRC_FOLDER_NAME="gcc"
      XBB_GCC_ARCHIVE_NAME="gcc-arm-none-eabi-${XBB_ARM_RELEASE}.tar.xz"
      XBB_GCC_ARCHIVE_URL="${XBB_ARM_URL_BASE}/gcc.tar.xz"

      XBB_GCC_PATCH_FILE_NAME="gcc-${XBB_GCC_VERSION}-cross.patch.diff"
      XBB_GCC_MULTILIB_LIST="aprofile,rmprofile"

      # ---------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://sourceware.org/git/newlib-cygwin.git
      # Revision: 2a3a03972b35377aef8d3d52d873ac3b8fcc512c

      XBB_NEWLIB_VERSION="4.1.0"
      XBB_NEWLIB_SRC_FOLDER_NAME="newlib-cygwin"
      XBB_NEWLIB_ARCHIVE_NAME="newlib-arm-none-eabi-${XBB_ARM_RELEASE}.tar.xz"
      XBB_NEWLIB_ARCHIVE_URL="${XBB_ARM_URL_BASE}/newlib-cygwin.tar.xz"

      # ---------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: gdb-11-branch
      # Revision: a10d1f2c33a9a329f3a3006e07cfe872a7cc965b

      # https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/gdb-11-arm-none-eabi-11.2-2022.02.tar.gz

      # From `gdb/version.in`
      XBB_GDB_VERSION="11.2"
      XBB_GDB_TAG_NAME="gdb-11-arm-none-eabi-${XBB_ARM_RELEASE}"

      XBB_GDB_SRC_FOLDER_NAME="binutils-gdb-${XBB_GDB_TAG_NAME}"
      XBB_GDB_ARCHIVE_NAME="${XBB_GDB_TAG_NAME}.tar.gz"
      XBB_GDB_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${XBB_GDB_ARCHIVE_NAME}"

      # Mandatory, otherwise gdb-py3 is not relocatable.
      XBB_GDB_PATCH_FILE_NAME="gdb-${XBB_GDB_VERSION}-cross.patch.diff"

    fi

    # https://www.python.org/ftp/python/
    # Requires `scripts/helper/extras/python/pyconfig-win-3.10.4.h` &
    # `python3-config.sh`

    XBB_WITH_GDB_PY3="y"

    XBB_PYTHON3_VERSION="3.10.4"
    XBB_PYTHON3_VERSION_MAJOR=$(echo ${XBB_PYTHON3_VERSION} | sed -e 's|\([0-9]\)\..*|\1|')
    XBB_PYTHON3_VERSION_MINOR=$(echo ${XBB_PYTHON3_VERSION} | sed -e 's|\([0-9]\)\.\([0-9][0-9]*\)\..*|\2|')

    # -------------------------------------------------------------------------
    # Build the native dependencies.

    # None.

    # -------------------------------------------------------------------------
    # Build the target dependencies.

    xbb_reset_env
    xbb_set_target "requested"

    if [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      prepare_gcc_env "${XBB_APPLICATION_TARGET_TRIPLET}-"
    fi

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

    # https://ftp.gnu.org/pub/gnu/libiconv/
    # Arm: In `configure`, search for `PACKAGE_VERSION=`.
    build_libiconv "1.15"

    # https://sourceforge.net/projects/lzmautils/files/
    build_xz "5.2.5" # "5.2.3"

    # -----------------------------------------------------------------------
    # GDB dependencies

    # https://github.com/libexpat/libexpat/releases
    # Arm: from release notes
    # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads-1
    build_expat "2.2.5" # "2.1.1"

    # Fails on mingw. 0.8.13 is deprecated. Not used anyway.
    # build_libelf "0.8.13"

    # http://ftp.gnu.org/pub/gnu/gettext/
    build_gettext "0.21"

    # Used by ncurses. Fails on macOS.
    if [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then
      # https://github.com/telmich/gpm/tags
      # https://github.com/xpack-dev-tools/gpm/tags
      build_gpm "1.20.7-1" # "1.20.7"
    fi

    if [ "${XBB_HOST_PLATFORM}" == "linux" -o "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      # https://ftp.gnu.org/gnu/ncurses/
      build_ncurses "6.3" # "6.2"

      # https://ftp.gnu.org/gnu/readline/
      build_readline "8.1" # "8.0" # requires ncurses

      # https://sourceware.org/pub/bzip2/
      build_bzip2 "1.0.8"
      # https://github.com/libffi/libffi/releases
      build_libffi  "3.4.2" # "3.3"
    fi

    if [ "${XBB_WITH_GDB_PY3}" == "y" ]
    then
      if [ "${XBB_HOST_PLATFORM}" == "linux" -o "${XBB_HOST_PLATFORM}" == "darwin" ]
      then
        # We cannot rely on a python shared library in the system, even
        # the custom build from sources does not have one.

        # https://www.bytereef.org/mpdecimal/download.html
        build_mpdecimal "2.5.1" # "2.5.0" # Used by Python

        # Required by a Python 3 module.
        # https://www.sqlite.org/download.html
        build_sqlite  "3380200" # "3.32.3"

        # Replacement for the old libcrypt.so.1; required by Python 3.
        # https://github.com/besser82/libxcrypt/releases
        build_libxcrypt "4.4.28" # "4.4.17"

        # https://www.openssl.org/source/
        build_openssl "1.1.1q" # "1.1.1n" # "1.1.1l" # "1.1.1h"
      fi
    fi

    # -----------------------------------------------------------------------
    # Build the application binaries.

    xbb_set_executables_install_path "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
    xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

    build_binutils_cross "${XBB_BINUTILS_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}"

    # -----------------------------------------------------------------------

    if [ "${XBB_HOST_PLATFORM}" == "linux" -o "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      build_cross_gcc_first "${XBB_GCC_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}"

      build_cross_newlib "${XBB_NEWLIB_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}"
      build_cross_gcc_final "${XBB_GCC_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}"

      # ---------------------------------------------------------------------
      # The nano version is practically a new build installed in a
      # separate folder.
      (
        xbb_set_executables_install_path "${XBB_APPLICATION_NANO_INSTALL_FOLDER_PATH}"

        # Although in the initial versions this was a copy, it is cleaner
        # to do it again.
        build_binutils_cross "${XBB_BINUTILS_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}" --nano

        build_cross_newlib "${XBB_NEWLIB_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}" --nano
        build_cross_gcc_final "${XBB_GCC_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}" --nano

        cross_gcc_copy_nano_multilibs "${XBB_APPLICATION_TARGET_TRIPLET}"
      )
    elif [ "${XBB_HOST_PLATFORM}" == "win32" ]
    then
      copy_cross_linux_libs "${XBB_APPLICATION_TARGET_TRIPLET}"
      build_cross_gcc_final ""
    fi

    build_cross_gdb "${XBB_APPLICATION_TARGET_TRIPLET}" ""

  if true
  then

    if [ "${XBB_WITH_GDB_PY3}" == "y" ]
    then
      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # Shortcut, use the existing python.exe instead of building
        # if from sources. It also downloads the sources.
        python3_download_win "${XBB_PYTHON3_VERSION}"
        python3_add_win_syslibs
      else # linux or darwin
        build_python3 "${XBB_PYTHON3_VERSION}"
        python3_add_syslibs
      fi

      build_cross_gdb "${XBB_APPLICATION_TARGET_TRIPLET}" "-py3"
    fi
  fi

  else
    echo "Unsupported ${XBB_APPLICATION_LOWER_CASE_NAME} version ${XBB_RELEASE_VERSION}"
    exit 1
  fi

  # ---------------------------------------------------------------------------

  cross_gcc_tidy_up

  if [ "${XBB_HOST_PLATFORM}" != "win32" ]
  then
    cross_gcc_strip_libs "${XBB_APPLICATION_TARGET_TRIPLET}"
  fi

  cross_gcc_final_tunings

  # ---------------------------------------------------------------------------
}

# -----------------------------------------------------------------------------
