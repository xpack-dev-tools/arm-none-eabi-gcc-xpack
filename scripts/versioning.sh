# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function application_build_versioned_components()
{
  # This definition also enables building newlib-nano.
  XBB_NEWLIB_NANO_SUFFIX="-nano"

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

  XBB_FIX_LTO_PLUGIN="y"

  XBB_NCURSES_DISABLE_WIDEC="y"

  XBB_WITH_GDB_PY3=""

  # ---------------------------------------------------------------------------

  XBB_GCC_VERSION="$(xbb_strip_version_pre_release "${XBB_RELEASE_VERSION}")"
  XBB_GCC_VERSION_MAJOR=$(xbb_get_version_major "${XBB_GCC_VERSION}")

  # In reverse chronological order.
  # Keep them in sync with the release manifest.txt file.
  # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads

  if [[ "${XBB_RELEASE_VERSION}" =~ 12[.].*[.].*-.* ]]
  then

    if [[ "${XBB_RELEASE_VERSION}" =~ 12[.]3[.]1-.* ]]
    then
      # https://developer.arm.com/-/media/Files/downloads/gnu/12.3.rel1/manifest/arm-gnu-toolchain-arm-none-eabi-abe-manifest.txt

      XBB_ARM_RELEASE="12.3.rel1"
      XBB_ARM_URL_BASE="https://developer.arm.com/-/media/Files/downloads/gnu/${XBB_ARM_RELEASE}/src"

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: binutils-2_40-branch
      # Revision: 28cb7cd2300df920d6e676af840a7e7970f0d7e6 (from manifest.txt)

      # https://github.com/xpack-dev-tools/binutils-gdb/tags

      XBB_BINUTILS_VERSION="2.40"
      XBB_BINUTILS_TAG_NAME="binutils-${XBB_BINUTILS_VERSION}-arm-none-eabi-${XBB_ARM_RELEASE}"

      XBB_BINUTILS_SRC_FOLDER_NAME="binutils-gdb-${XBB_BINUTILS_TAG_NAME}"
      XBB_BINUTILS_ARCHIVE_NAME="${XBB_BINUTILS_TAG_NAME}.tar.gz"
      XBB_BINUTILS_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${XBB_BINUTILS_ARCHIVE_NAME}"

      XBB_BINUTILS_PATCH_FILE_NAME="binutils-${XBB_BINUTILS_VERSION}.patch"

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: gdb-13-branch
      # Revision: 65ba4a63fa998cc2f324773b66754fe6c67a8fd0 (from manifext.txt)

      # https://github.com/xpack-dev-tools/binutils-gdb/tags/

      # From `gdb/version.in`
      XBB_GDB_VERSION="13.2"
      XBB_GDB_TAG_NAME="gdb-13-arm-none-eabi-${XBB_ARM_RELEASE}"

      XBB_GDB_SRC_FOLDER_NAME="binutils-gdb-${XBB_GDB_TAG_NAME}"
      XBB_GDB_ARCHIVE_NAME="${XBB_GDB_TAG_NAME}.tar.gz"
      XBB_GDB_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${XBB_GDB_ARCHIVE_NAME}"

      # Mandatory, otherwise gdb-py3 is not relocatable.
      XBB_GDB_PATCH_FILE_NAME="gdb-${XBB_GDB_VERSION}-cross.git.patch"

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://gcc.gnu.org/git/gcc.git
      # Branch: refs/vendors/ARM/heads/arm-12
      # Revision: ?

      # XBB_GCC_VERSION computer from XBB_RELEASE_VERSION
      XBB_GCC_SRC_FOLDER_NAME="gcc"
      XBB_GCC_ARCHIVE_NAME="gcc-arm-none-eabi-${XBB_ARM_RELEASE}.tar.xz"
      XBB_GCC_ARCHIVE_URL="${XBB_ARM_URL_BASE}/gcc.tar.xz"

      XBB_GCC_PATCH_FILE_NAME="gcc-${XBB_GCC_VERSION}-cross.git.patch"

      XBB_GCC_MULTILIB_LIST="aprofile,rmprofile"

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # https://www.sourceware.org/newlib/
      # Repository: git://sourceware.org/git/newlib-cygwin.git
      # Revision: ?

      # From newlib/configure PACKAGE_VERSION=
      XBB_NEWLIB_VERSION="4.3.0"
      XBB_NEWLIB_SRC_FOLDER_NAME="newlib-cygwin"
      XBB_NEWLIB_ARCHIVE_NAME="newlib-arm-none-eabi-${XBB_ARM_RELEASE}.tar.xz"
      XBB_NEWLIB_ARCHIVE_URL="${XBB_ARM_URL_BASE}/newlib-cygwin.tar.xz"

    elif [[ "${XBB_RELEASE_VERSION}" =~ 12[.]2[.]1-.* ]]
    then
      # https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/manifest/arm-gnu-toolchain-arm-none-eabi-abe-manifest.txt

      XBB_ARM_RELEASE="12.2.rel1"
      XBB_ARM_URL_BASE="https://developer.arm.com/-/media/Files/downloads/gnu/${XBB_ARM_RELEASE}/src"

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: binutils-2_39-branch
      # Revision: 6df169f352d9596ac210c5e39f49aa83c1ae46e5

      # https://github.com/xpack-dev-tools/binutils-gdb/tags

      XBB_BINUTILS_VERSION="2.39"
      XBB_BINUTILS_TAG_NAME="binutils-${XBB_BINUTILS_VERSION}-arm-none-eabi-${XBB_ARM_RELEASE}"

      XBB_BINUTILS_SRC_FOLDER_NAME="binutils-gdb-${XBB_BINUTILS_TAG_NAME}"
      XBB_BINUTILS_ARCHIVE_NAME="${XBB_BINUTILS_TAG_NAME}.tar.gz"
      XBB_BINUTILS_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${XBB_BINUTILS_ARCHIVE_NAME}"

      XBB_BINUTILS_PATCH_FILE_NAME="binutils-${XBB_BINUTILS_VERSION}.patch"

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://sourceware.org/git/binutils-gdb.git
      # Branch: gdb-12-branch
      # Revision: ed9b90db517c3e900481d4c9eadca736870f7871

      # https://github.com/xpack-dev-tools/binutils-gdb/tags/

      # From `gdb/version.in`
      XBB_GDB_VERSION="12.1"
      XBB_GDB_TAG_NAME="gdb-12-arm-none-eabi-${XBB_ARM_RELEASE}"

      XBB_GDB_SRC_FOLDER_NAME="binutils-gdb-${XBB_GDB_TAG_NAME}"
      XBB_GDB_ARCHIVE_NAME="${XBB_GDB_TAG_NAME}.tar.gz"
      XBB_GDB_ARCHIVE_URL="https://github.com/xpack-dev-tools/binutils-gdb/archive/refs/tags/${XBB_GDB_ARCHIVE_NAME}"

      # Mandatory, otherwise gdb-py3 is not relocatable.
      XBB_GDB_PATCH_FILE_NAME="gdb-${XBB_GDB_VERSION}-cross.git.patch"

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://gcc.gnu.org/git/gcc.git
      # Branch: refs/vendors/ARM/heads/arm-12
      # Revision: ed5092f464a08af47b8a75a3601e7bd6f7e14e8b

      # XBB_GCC_VERSION computer from XBB_RELEASE_VERSION
      XBB_GCC_SRC_FOLDER_NAME="gcc"
      XBB_GCC_ARCHIVE_NAME="gcc-arm-none-eabi-${XBB_ARM_RELEASE}.tar.xz"
      XBB_GCC_ARCHIVE_URL="${XBB_ARM_URL_BASE}/gcc.tar.xz"

      XBB_GCC_PATCH_FILE_NAME="gcc-${XBB_GCC_VERSION}-cross.git.patch"

      XBB_GCC_MULTILIB_LIST="aprofile,rmprofile"

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # https://www.sourceware.org/newlib/
      # Repository: git://sourceware.org/git/newlib-cygwin.git
      # Revision: faac79783c27c030ab17a6f298f8aa89c51a03c5

      # From newlib/configure PACKAGE_VERSION=
      XBB_NEWLIB_VERSION="4.2.0"
      XBB_NEWLIB_SRC_FOLDER_NAME="newlib-cygwin"
      XBB_NEWLIB_ARCHIVE_NAME="newlib-arm-none-eabi-${XBB_ARM_RELEASE}.tar.xz"
      XBB_NEWLIB_ARCHIVE_URL="${XBB_ARM_URL_BASE}/newlib-cygwin.tar.xz"

    else
      echo "Unsupported ${XBB_APPLICATION_LOWER_CASE_NAME} version ${XBB_RELEASE_VERSION} in ${FUNCNAME[0]}()"
      exit 1
    fi


    # https://www.python.org/ftp/python/
    # Requires `scripts/helper/extras/python/pyconfig-win-3.10.4.h` &
    # `python3-config.sh`

    XBB_WITH_GDB_PY3="y"

    export XBB_PYTHON3_VERSION="3.11.1" # "3.10.4"
    export XBB_PYTHON3_VERSION_MAJOR=$(xbb_get_version_major "${XBB_PYTHON3_VERSION}" )
    export XBB_PYTHON3_VERSION_MINOR=$(xbb_get_version_minor "${XBB_PYTHON3_VERSION}")

    # Explicit, since it is also used in python3_copy_syslibs
    export XBB_PYTHON3_SRC_FOLDER_NAME="Python-${XBB_PYTHON3_VERSION}"

    # https://ftp.gnu.org/pub/gnu/libiconv/
    XBB_LIBICONV_VERSION="1.15" # Arm

    # https://zlib.net/fossils/
    XBB_ZLIB_VERSION="1.2.13" # "1.2.12"

    # https://gmplib.org/download/gmp/
    # Arm: In `gmp-h.in` search for `__GNU_MP_VERSION`.
    XBB_GMP_VERSION="6.2.1" # Arm 6.2

    # https://www.mpfr.org/history.html
    # Arm: In `VERSION`.
    XBB_MPFR_VERSION="3.1.6" # Arm

    # https://www.multiprecision.org/mpc/download.html
    # Arm: In `configure`, search for `VERSION=`.
    XBB_MPC_VERSION="1.0.3" # Arm

    # https://sourceforge.net/projects/libisl/files/
    # Arm: In `configure`, search for `PACKAGE_VERSION=`.
    XBB_ISL_VERSION="0.15" # arm

    # https://sourceforge.net/projects/lzmautils/files/
    XBB_XZ_VERSION="5.4.1" # "5.2.5"

    # https://github.com/facebook/zstd/releases
    XBB_ZSTD_VERSION="1.5.2"

    # -------------------------------------------------------------------------
    # Build the native dependencies.

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
    then
      echo
      echo "# Building a bootstrap compiler..."

      gcc_cross_build_dependencies

      gcc_cross_build_all "${XBB_APPLICATION_TARGET_TRIPLET}"
    fi

    # -------------------------------------------------------------------------
    # Build the target dependencies.

    xbb_reset_env
    xbb_set_target "requested"

    # Adjust environent to refer to the flex dependency.
    local realpath="$(which_realpath)"
    local flex_realpath="$(${realpath} "$(which flex)")"
    XBB_FLEX_PACKAGE_PATH="$(dirname $(dirname "${flex_realpath}"))"

    export XBB_CPPFLAGS+=" -I${XBB_FLEX_PACKAGE_PATH}/include"
    export XBB_LDFLAGS+=" -L${XBB_FLEX_PACKAGE_PATH}/lib"
    export XBB_LDFLAGS_LIB+=" -L${XBB_FLEX_PACKAGE_PATH}/lib"
    export XBB_LDFLAGS_APP+=" -L${XBB_FLEX_PACKAGE_PATH}/lib"
    export XBB_LDFLAGS_APP_STATIC_GCC+=" -L${XBB_FLEX_PACKAGE_PATH}/lib"
    echo_develop "XBB_FLEX_PACKAGE_PATH=${XBB_FLEX_PACKAGE_PATH}"

    gcc_cross_build_dependencies

    # -------------------------------------------------------------------------
    # GDB dependencies

    # https://github.com/libexpat/libexpat/releases
    # Arm: from release notes
    # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads-1
    XBB_EXPAT_VERSION="2.2.5"

    # https://ftp.gnu.org/gnu/libunistring/
    XBB_LIBUNISTRING_VERSION="1.1"

    # https://ftp.gnu.org/pub/gnu/gettext/
    XBB_GETTEXT_VERSION="0.21"

    # https://github.com/telmich/gpm/tags
    # https://github.com/xpack-dev-tools/gpm/tags
    XBB_GPM_VERSION="1.20.7-1"

    # https://ftp.gnu.org/gnu/ncurses/
    XBB_NCURSES_VERSION="6.4" # "6.3"

    # https://ftp.gnu.org/gnu/readline/
    XBB_READLINE_VERSION="8.2" # "8.1"

    # https://sourceware.org/pub/bzip2/
    XBB_BZIP2_VERSION="1.0.8"

    # https://github.com/libffi/libffi/releases
    XBB_LIBFFI_VERSION="3.4.4" # "3.4.2"

    # https://www.bytereef.org/mpdecimal/download.html
    XBB_MPDECIMAL_VERSION="2.5.1"

    # Required by a Python 3 module.
    # https://www.sqlite.org/download.html
    XBB_SQLITE_VERSION="3400100" # "3380200"

    # Replacement for the old libcrypt.so.1; required by Python 3.
    # https://github.com/besser82/libxcrypt/releases
    XBB_LIBXCRYPT_VERSION="4.4.33" # "4.4.28"

    # https://www.openssl.org/source/
    XBB_OPENSSL_VERSION="1.1.1s" # "1.1.1q"

    gdb_cross_build_dependencies

    # -------------------------------------------------------------------------
    # Build the application binaries.

    xbb_set_executables_install_path "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
    xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

    # -------------------------------------------------------------------------

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
    then
      binutils_cross_build "${XBB_BINUTILS_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}"

      # As usual, for Windows things require more innovtive solutions.
      # In this case the libraries are copied from the bootstrap,
      # and only the executables are build for Windows.
      gcc_cross_copy_linux_libs "${XBB_APPLICATION_TARGET_TRIPLET}"

      (
        # To access the bootstrap compiler.
        xbb_activate_installed_bin

        gcc_cross_build_final "${XBB_GCC_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}"
      )
    else
      # For macOS & GNU/Linux build the toolchain natively.
      gcc_cross_build_all "${XBB_APPLICATION_TARGET_TRIPLET}"
    fi

    gdb_cross_build "${XBB_APPLICATION_TARGET_TRIPLET}" ""

    if [ "${XBB_WITH_GDB_PY3}" == "y" ]
    then
      if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
      then
        # Shortcut, use the existing python.exe instead of building
        # if from sources. It also downloads the sources.
        python3_download_win "${XBB_PYTHON3_VERSION}"
        python3_copy_win_syslibs
      else # linux or darwin
        # Copy libraries from sources and dependencies.
        python3_copy_syslibs
      fi

      gdb_cross_build "${XBB_APPLICATION_TARGET_TRIPLET}" "-py3"
    fi
  elif [[ "${XBB_RELEASE_VERSION}" =~ 11[.].*[.].*-.* ]]
  then

    if [[ "${XBB_RELEASE_VERSION}" =~ 11[.]3[.]1-.* ]]
    then
      # https://developer.arm.com/-/media/Files/downloads/gnu/11.3.rel1/manifest/arm-gnu-toolchain-arm-none-eabi-abe-manifest.txt

      XBB_ARM_RELEASE="11.3.rel1"
      XBB_ARM_URL_BASE="https://developer.arm.com/-/media/Files/downloads/gnu/${XBB_ARM_RELEASE}/src"

      # -----------------------------------------------------------------------

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

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # Repository: git://gcc.gnu.org/git/gcc.git
      # Branch: refs/vendors/ARM/heads/arm-11
      # Revision: 4249a65c814287af667aa78789436d3fc618e80a

      # XBB_GCC_VERSION computer from XBB_RELEASE_VERSION
      XBB_GCC_SRC_FOLDER_NAME="gcc"
      XBB_GCC_ARCHIVE_NAME="gcc-arm-none-eabi-${XBB_ARM_RELEASE}.tar.xz"
      XBB_GCC_ARCHIVE_URL="${XBB_ARM_URL_BASE}/gcc.tar.xz"

      XBB_GCC_PATCH_FILE_NAME="gcc-${XBB_GCC_VERSION}-cross.git.patch"
      XBB_GCC_MULTILIB_LIST="aprofile,rmprofile"

      # -----------------------------------------------------------------------

      # Arm: release notes.
      # https://www.sourceware.org/newlib/
      # Repository: git://sourceware.org/git/newlib-cygwin.git
      # Revision: bfee9c6ab0c3c9a5742e84509d01ec6472aa62c4

      XBB_NEWLIB_VERSION="4.1.0"
      XBB_NEWLIB_SRC_FOLDER_NAME="newlib-cygwin"
      XBB_NEWLIB_ARCHIVE_NAME="newlib-arm-none-eabi-${XBB_ARM_RELEASE}.tar.xz"
      XBB_NEWLIB_ARCHIVE_URL="${XBB_ARM_URL_BASE}/newlib-cygwin.tar.xz"

      # -----------------------------------------------------------------------

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
      XBB_GDB_PATCH_FILE_NAME="gdb-${XBB_GDB_VERSION}-cross.git.patch"

    elif [[ "${XBB_RELEASE_VERSION}" =~ 11[.]2[.]1-.* ]]
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

      XBB_GCC_PATCH_FILE_NAME="gcc-${XBB_GCC_VERSION}-cross.git.patch"
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
      XBB_GDB_PATCH_FILE_NAME="gdb-${XBB_GDB_VERSION}-cross.git.patch"

    fi

    # https://www.python.org/ftp/python/
    # Requires `scripts/helper/extras/python/pyconfig-win-3.10.4.h` &
    # `python3-config.sh`

    XBB_WITH_GDB_PY3="y"

    export XBB_PYTHON3_VERSION="3.10.4"
    export XBB_PYTHON3_VERSION_MAJOR=$(xbb_get_version_major "${XBB_PYTHON3_VERSION}" )
    export XBB_PYTHON3_VERSION_MINOR=$(xbb_get_version_minor "${XBB_PYTHON3_VERSION}")

    # Explicit, since it is also used in python3_copy_syslibs
    export XBB_PYTHON3_SRC_FOLDER_NAME="Python-${XBB_PYTHON3_VERSION}"

    # https://ftp.gnu.org/pub/gnu/libiconv/
    XBB_LIBICONV_VERSION="1.15"

    # https://zlib.net/fossils/
    XBB_ZLIB_VERSION="1.2.12"

    # https://gmplib.org/download/gmp/
    # Arm: In `gmp-h.in` search for `__GNU_MP_VERSION`.
    XBB_GMP_VERSION="6.2.1"

    # https://www.mpfr.org/history.html
    # Arm: In `VERSION`.
    XBB_MPFR_VERSION="3.1.6"

    # https://www.multiprecision.org/mpc/download.html
    # Arm: In `configure`, search for `VERSION=`.
    XBB_MPC_VERSION="1.0.3"

    # https://sourceforge.net/projects/libisl/files/
    # Arm: In `configure`, search for `PACKAGE_VERSION=`.
    XBB_ISL_VERSION="0.15"

    # https://sourceforge.net/projects/lzmautils/files/
    XBB_XZ_VERSION="5.2.5"

    # https://github.com/facebook/zstd/releases
    XBB_ZSTD_VERSION="1.5.2"

    # -------------------------------------------------------------------------
    # Build the native dependencies.

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
    then
      echo
      echo "# Building a bootstrap compiler..."

      gcc_cross_build_dependencies

      gcc_cross_build_all "${XBB_APPLICATION_TARGET_TRIPLET}"
    fi

    # -------------------------------------------------------------------------
    # Build the target dependencies.

    xbb_reset_env
    xbb_set_target "requested"

    gcc_cross_build_dependencies

    # -------------------------------------------------------------------------
    # GDB dependencies

    # https://github.com/libexpat/libexpat/releases
    # Arm: from release notes
    # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads-1
    XBB_EXPAT_VERSION="2.2.5"

    # https://ftp.gnu.org/pub/gnu/gettext/
    XBB_GETTEXT_VERSION="0.21"

    # https://github.com/telmich/gpm/tags
    # https://github.com/xpack-dev-tools/gpm/tags
    XBB_GPM_VERSION="1.20.7-1"

    # https://ftp.gnu.org/gnu/ncurses/
    XBB_NCURSES_VERSION="6.3"

    # https://ftp.gnu.org/gnu/readline/
    XBB_READLINE_VERSION="8.1"

    # https://sourceware.org/pub/bzip2/
    XBB_BZIP2_VERSION="1.0.8"

    # https://github.com/libffi/libffi/releases
    XBB_LIBFFI_VERSION="3.4.2"

    # https://www.bytereef.org/mpdecimal/download.html
    XBB_MPDECIMAL_VERSION="2.5.1"

    # Required by a Python 3 module.
    # https://www.sqlite.org/download.html
    XBB_SQLITE_VERSION="3380200"

    # Replacement for the old libcrypt.so.1; required by Python 3.
    # https://github.com/besser82/libxcrypt/releases
    XBB_LIBXCRYPT_VERSION="4.4.28"

    # https://www.openssl.org/source/
    XBB_OPENSSL_VERSION="1.1.1q"

    gdb_cross_build_dependencies

    # -------------------------------------------------------------------------
    # Build the application binaries.

    xbb_set_executables_install_path "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
    xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

    # -------------------------------------------------------------------------

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
    then
      binutils_cross_build "${XBB_BINUTILS_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}"

      # As usual, for Windows things require more innovtive solutions.
      # In this case the libraries are copied from the bootstrap,
      # and only the executables are build for Windows.
      gcc_cross_copy_linux_libs "${XBB_APPLICATION_TARGET_TRIPLET}"

      (
        # To access the bootstrap compiler.
        xbb_activate_installed_bin

        gcc_cross_build_final "${XBB_GCC_VERSION}" "${XBB_APPLICATION_TARGET_TRIPLET}"
      )
    else
      # For macOS & GNU/Linux build the toolchain natively.
      gcc_cross_build_all "${XBB_APPLICATION_TARGET_TRIPLET}"
    fi

    gdb_cross_build "${XBB_APPLICATION_TARGET_TRIPLET}" ""

    if [ "${XBB_WITH_GDB_PY3}" == "y" ]
    then
      if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
      then
        # Shortcut, use the existing python.exe instead of building
        # if from sources. It also downloads the sources.
        python3_download_win "${XBB_PYTHON3_VERSION}"
        python3_copy_win_syslibs
      else # linux or darwin
        # Copy libraries from sources and dependencies.
        python3_copy_syslibs
      fi

      gdb_cross_build "${XBB_APPLICATION_TARGET_TRIPLET}" "-py3"
    fi

  else
    echo "Unsupported ${XBB_APPLICATION_LOWER_CASE_NAME} version ${XBB_RELEASE_VERSION}in ${FUNCNAME[0]}()"
    exit 1
  fi

  # ---------------------------------------------------------------------------

  gcc_cross_tidy_up

  if [ "${XBB_REQUESTED_HOST_PLATFORM}" != "win32" ]
  then
    gcc_cross_strip_libs "${XBB_APPLICATION_TARGET_TRIPLET}"
  fi

  gcc_cross_final_tunings

  # ---------------------------------------------------------------------------
}

# -----------------------------------------------------------------------------
