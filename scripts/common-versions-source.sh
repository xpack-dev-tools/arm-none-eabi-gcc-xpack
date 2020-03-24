# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the second edition of the GNU MCU Eclipse build 
# scripts. As the name implies, it should contain only functions and 
# should be included with 'source' by the container build scripts.

# -----------------------------------------------------------------------------

function prepare_versions()
{
  APP_PREFIX_NANO="${INSTALL_FOLDER_PATH}/${APP_LC_NAME}-nano"

  # The \x2C is a comma in hex; without this trick the regular expression
  # that processes this string in bfd/Makefile, silently fails and the 
  # bfdver.h file remains empty.
  # XBB v3.1 update: newer tools expand the unicode and bfd/Makefile.in needs
  # a patch to avoid the comma separator.
  BRANDING="${BRANDING}\x2C ${TARGET_BITS}-bit"

  CFLAGS_OPTIMIZATIONS_FOR_TARGET="-ffunction-sections -fdata-sections -O2"

  # https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads
  # https://gcc.gnu.org/viewcvs/gcc/branches/ARM/

  # For the main GCC version, check gcc/BASE-VER.

  # -----------------------------------------------------------------------------
  # Defaults. Must be present.

  # Redefine to existing file names to enable patches.
  BINUTILS_PATCH=""
  GCC_PATCH=""
  GDB_PATCH=""
  HAS_WINPTHREAD=""

  BINUTILS_PROJECT_NAME="binutils-gdb"
  BINUTILS_GIT_URL=""

  WITH_GDB_PY="y"
  WITH_GDB_PY3=""
  PYTHON3_VERSION=""
  USE_PLATFORM_PYTHON=""
  USE_PLATFORM_PYTHON3=""

  # Redefine to actual URL if the build should use the Git sources.
  # Also be sure GDB_GIT_BRANCH and GDB_GIT_COMMIT are defined
  GDB_GIT_URL=""
  # Defined for completeness, not yet used by download_gdb().
  GDB_ARCHIVE_URL=""

  MULTILIB_FLAGS=""
  GETTEXT_VERSION=""

  USE_SINGLE_FOLDER=""
  USE_TAR_GZ=""

  NCURSES_VERSION=""
  GPM_VERSION=""

  # -----------------------------------------------------------------------------

  # Redefine to "y" to create the LTO plugin links.
  FIX_LTO_PLUGIN=""
  if [ "${TARGET_PLATFORM}" == "darwin" ]
  then
    LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin.0.so"
    LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin.so"
  elif [ "${TARGET_PLATFORM}" == "linux" ]
  then
    LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin.so.0.0.0"
    LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin.so"
  elif [ "${TARGET_PLATFORM}" == "win32" ]
  then
    LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin-0.dll"
    LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin-0.dll"
  fi

  FIX_LTO_PLUGIN="y"

  # -----------------------------------------------------------------------------

  README_OUT_FILE_NAME="README-${RELEASE_VERSION}.md"

  # In reverse chronological order.
  # Keep them in sync with combo archive content.
  # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads
  if [[ "${RELEASE_VERSION}" =~ 9\.2\.1-* ]]
  then

    # https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-src.tar.bz2
    GCC_COMBO_VERSION_MAJOR="9"
    GCC_COMBO_VERSION_YEAR="2019"
    GCC_COMBO_VERSION_QUARTER="q4"
    GCC_COMBO_VERSION_KIND="major"
    GCC_COMBO_VERSION_SUBFOLDER=""

    GCC_COMBO_VERSION="${GCC_COMBO_VERSION_MAJOR}-${GCC_COMBO_VERSION_YEAR}-${GCC_COMBO_VERSION_QUARTER}-${GCC_COMBO_VERSION_KIND}"
    GCC_COMBO_FOLDER_NAME="gcc-arm-none-eabi-${GCC_COMBO_VERSION}"
    GCC_COMBO_ARCHIVE="${GCC_COMBO_FOLDER_NAME}-src.tar.bz2"

    GCC_COMBO_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/${GCC_COMBO_VERSION_MAJOR}-${GCC_COMBO_VERSION_YEAR}${GCC_COMBO_VERSION_QUARTER}${GCC_COMBO_VERSION_SUBFOLDER}/${GCC_COMBO_ARCHIVE}"

    MULTILIB_FLAGS="--with-multilib-list=rmprofile"

    # From /release.txt
    BINUTILS_VERSION="2.32"

    # From gcc/BASE_VER. 
    # gcc/LAST_UPDATED: Wed Oct 30 01:03:41 UTC 2019 (revision 277599)
    GCC_VERSION="9.2.1"

    # git: 572687310059534b2da9428ca19df992509c8a5d from /release.txt.
    # VERSION from configure, comment in NEWS.
    NEWLIB_VERSION="3.1.0"

    # git: e908e11a4f74ab6a06aef8c302a03b2a0dbc4d83 from /release.txt
    GDB_VERSION="8.3"

    ZLIB_VERSION="1.2.8"
    GMP_VERSION="6.1.0"
    MPFR_VERSION="3.1.4"
    MPC_VERSION="1.0.3"

    ISL_VERSION="0.18"

    LIBELF_VERSION="0.8.13"
    EXPAT_VERSION="2.1.1"
    LIBICONV_VERSION="1.15"
    XZ_VERSION="5.2.3"
    GETTEXT_VERSION="0.19.8.1"

    # Arm uses 2.7.7
    PYTHON_WIN_VERSION="2.7.13" # -> 2.7.17

    # GDB 8.3 with Python3 not yet functional on Windows.
    # GDB does not know the Python3 API when compiled with mingw.
    if [ "${TARGET_PLATFORM}" != "win32" ]
    then
      WITH_GDB_PY3="y" 
      PYTHON3_VERSION="3.7.2" # -> 3.7.6
    fi

    if [ "${TARGET_PLATFORM}" == "darwin" ]
    then
      USE_PLATFORM_PYTHON="y"
    fi
    USE_SINGLE_FOLDER="y"
    USE_TAR_GZ="y"

    BINUTILS_PATCH="binutils-${BINUTILS_VERSION}.patch"

    if [ "${RELEASE_VERSION}" != "9.2.1-1.1" ]
    then
      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        USE_PLATFORM_PYTHON="n"
        USE_PLATFORM_PYTHON3="n"
      fi
      GDB_PATCH="gdb-${GDB_VERSION}.patch"
      USE_SINGLE_FOLDER_PATH="y"

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then
        NCURSES_VERSION="6.2"
        GPM_VERSION="1.20.7"
      fi

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        WITH_GDB_PY="n"
        # PYTHON_WIN_VERSION="2.7.17"
      fi

      # https://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=commit;h=272044897e178835f596c96740c5a1800ec6f9fb
      WITH_GDB_PY3="y" 
      PYTHON3_VERSION="3.7.6"

    fi

  elif [[ "${RELEASE_VERSION}" =~ 8\.3\.1-* ]]
  then

    # https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2019q3/RC1.1/gcc-arm-none-eabi-8-2019-q3-update-src.tar.bz2
    GCC_COMBO_VERSION_MAJOR="8"
    GCC_COMBO_VERSION_YEAR="2019"
    GCC_COMBO_VERSION_QUARTER="q3"
    GCC_COMBO_VERSION_KIND="update"
    GCC_COMBO_VERSION_SUBFOLDER="/RC1.1"

    GCC_COMBO_VERSION="${GCC_COMBO_VERSION_MAJOR}-${GCC_COMBO_VERSION_YEAR}-${GCC_COMBO_VERSION_QUARTER}-${GCC_COMBO_VERSION_KIND}"
    GCC_COMBO_FOLDER_NAME="gcc-arm-none-eabi-${GCC_COMBO_VERSION}"
    GCC_COMBO_ARCHIVE="${GCC_COMBO_FOLDER_NAME}-src.tar.bz2"

    GCC_COMBO_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/${GCC_COMBO_VERSION_MAJOR}-${GCC_COMBO_VERSION_YEAR}${GCC_COMBO_VERSION_QUARTER}${GCC_COMBO_VERSION_SUBFOLDER}/${GCC_COMBO_ARCHIVE}"

    MULTILIB_FLAGS="--with-multilib-list=rmprofile"

    # From /release.txt
    BINUTILS_VERSION="2.32"

    # From gcc/BASE_VER. svn 273027 from LAST_UPDATED and /release.txt
    GCC_VERSION="8.3.1"

    # git: fff17ad73f6ae6b75ef293e17a837f23f6134753 from /release.txt.
    # VERSION from configure, comment in NEWS.
    NEWLIB_VERSION="3.1.0"

    # git: 66263c8cdba32ef18ae0dfabde0867b9b850c441 from /release.txt
    GDB_VERSION="8.3"

    ZLIB_VERSION="1.2.8"
    GMP_VERSION="6.1.0"
    MPFR_VERSION="3.1.4"
    MPC_VERSION="1.0.3"

    # Arm uses 0.15, not 0.18
    ISL_VERSION="0.15"

    LIBELF_VERSION="0.8.13"
    EXPAT_VERSION="2.1.1"
    LIBICONV_VERSION="1.14"
    XZ_VERSION="5.2.3"
    GETTEXT_VERSION="0.19.8.1"

    PYTHON_WIN_VERSION="2.7.13"

    # GDB 8.3 with Python3 not yet functional on Windows.
    # GDB does not know the Python3 API when compiled with mingw.
    if [ "${TARGET_PLATFORM}" != "win32" ]
    then
      WITH_GDB_PY3="y" 
      PYTHON3_VERSION="3.7.2"
    fi

    if [ "${RELEASE_VERSION}" != "8.3.1-1.1" \
      -a "${RELEASE_VERSION}" != "8.3.1-1.2" ]
    then
      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        USE_PLATFORM_PYTHON="y"
      fi
    fi

    if [ "${RELEASE_VERSION}" != "8.3.1-1.1" \
      -a "${RELEASE_VERSION}" != "8.3.1-1.2" \
      -a "${RELEASE_VERSION}" != "8.3.1-1.3" ]
    then
      # Versions 1.4 and up use the new linearised content, without
      # multiple folders.
      USE_SINGLE_FOLDER="y"
      USE_TAR_GZ="y"
    fi

    BINUTILS_PATCH="binutils-${BINUTILS_VERSION}.patch"
    # GDB_PATCH="gdb-${GDB_VERSION}.patch"

  elif [[ "${RELEASE_VERSION}" =~ 7\.3\.1-* ]]
  then

    # https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2018q2/gcc-arm-none-eabi-7-2018-q2-update-src.tar.bz2

    GCC_COMBO_VERSION_MAJOR="7"
    GCC_COMBO_VERSION_YEAR="2018"
    GCC_COMBO_VERSION_QUARTER="q2"
    GCC_COMBO_VERSION_KIND="update"

    GCC_COMBO_VERSION="${GCC_COMBO_VERSION_MAJOR}-${GCC_COMBO_VERSION_YEAR}-${GCC_COMBO_VERSION_QUARTER}-${GCC_COMBO_VERSION_KIND}"
    GCC_COMBO_FOLDER_NAME="gcc-arm-none-eabi-${GCC_COMBO_VERSION}"
    GCC_COMBO_ARCHIVE="${GCC_COMBO_FOLDER_NAME}-src.tar.bz2"

    GCC_COMBO_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/${GCC_COMBO_VERSION_MAJOR}-${GCC_COMBO_VERSION_YEAR}${GCC_COMBO_VERSION_QUARTER}/${GCC_COMBO_ARCHIVE}"

    MULTILIB_FLAGS="--with-multilib-list=rmprofile"

    BINUTILS_VERSION="2.30"
    # From gcc/BASE_VER; svn: 261907.
    GCC_VERSION="7.3.1"
    # git: 3ccfb407af410ba7e54ea0da11ae1e40b554a6f4.
    NEWLIB_VERSION="3.0.0"
    GDB_VERSION="8.1"

    ZLIB_VERSION="1.2.8"
    GMP_VERSION="6.1.0"
    MPFR_VERSION="3.1.4"
    MPC_VERSION="1.0.3"
    ISL_VERSION="0.15"
    LIBELF_VERSION="0.8.13"
    EXPAT_VERSION="2.1.1"
    LIBICONV_VERSION="1.14"
    XZ_VERSION="5.2.3"

    PYTHON_WIN_VERSION="2.7.13"

    BINUTILS_PATCH="binutils-${BINUTILS_VERSION}.patch"
    GDB_PATCH="gdb-${GDB_VERSION}.patch"

  else
    echo "Unsupported version ${RELEASE_VERSION}."
    exit 1
  fi

  # -----------------------------------------------------------------------------

  if [ ! -f "${BUILD_GIT_PATH}/scripts/${README_OUT_FILE_NAME}" ]
  then
    echo "Missing ${README_OUT_FILE_NAME}, quit."
    exit 1
  fi

  # -----------------------------------------------------------------------------

  # No versioning here, the inner archives use simple names.
  BINUTILS_SRC_FOLDER_NAME=${BINUTILS_SRC_FOLDER_NAME:-"binutils"}

  GCC_SRC_FOLDER_NAME=${GCC_SRC_FOLDER_NAME:-"gcc"}
  NEWLIB_SRC_FOLDER_NAME=${NEWLIB_SRC_FOLDER_NAME:-"newlib"}
  GDB_SRC_FOLDER_NAME=${GDB_SRC_FOLDER_NAME:-"gdb"}

  # Note: The 5.x build failed with various messages.

  if [ "${WITHOUT_MULTILIB}" == "y" ]
  then
    MULTILIB_FLAGS="--disable-multilib"
  fi

  # -----------------------------------------------------------------------------

  if [ "${TARGET_BITS}" == "32" ]
  then
    PYTHON_WIN=python-"${PYTHON_WIN_VERSION}"
  else
    PYTHON_WIN=python-"${PYTHON_WIN_VERSION}".amd64
  fi

  if [ ! -z "${PYTHON3_VERSION}" ]
  then
    PYTHON3_VERSION_MAJOR=$(echo ${PYTHON3_VERSION} | sed -e 's|\([0-9]\)\..*|\1|')
    PYTHON3_VERSION_MINOR=$(echo ${PYTHON3_VERSION} | sed -e 's|\([0-9]\)\.\([0-9][0-9]*\)\..*|\2|')

    # Version 3.7.2 uses a longer name, like python-3.7.2.post1-embed-amd64.zip.
    if [ "${TARGET_BITS}" == "32" ]
    then
      PYTHON3_WIN_EMBED_FOLDER_NAME=python-"${PYTHON3_VERSION}-embed-win32"
    else
      PYTHON3_WIN_EMBED_FOLDER_NAME=python-"${PYTHON3_VERSION}-embed-amd64"
    fi

    export PYTHON3_WIN_EMBED_FOLDER_NAME
    export PYTHON3_SRC_FOLDER_NAME="Python-${PYTHON3_VERSION}"
    export PYTHON3_FOLDER_NAME="Python-${PYTHON3_VERSION}"
  fi
}

# -----------------------------------------------------------------------------
