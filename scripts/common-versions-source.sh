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

function build_versions()
{
  APP_PREFIX_NANO="${INSTALL_FOLDER_PATH}/${APP_LC_NAME}-nano"

  # The \x2C is a comma in hex; without this trick the regular expression
  # that processes this string in bfd/Makefile, silently fails and the 
  # bfdver.h file remains empty.
  # XBB v3.1 update: newer tools expand the unicode and bfd/Makefile.in needs
  # a patch to avoid the comma separator.
  BRANDING="${BRANDING}\x2C ${TARGET_BITS}-bit"

  CFLAGS_OPTIMIZATIONS_FOR_TARGET="-ffunction-sections -fdata-sections -Ofast -w"

  # https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads
  # https://gcc.gnu.org/viewcvs/gcc/branches/ARM/

  # For the main GCC version, check gcc/BASE-VER.

  # ---------------------------------------------------------------------------
  # Defaults. Must be present.

  # Redefine to existing file names to enable patches.
  GCC_PATCH=""
  GDB_PATCH=""
  HAS_WINPTHREAD=""

  # Use it to download a separate binutils from Git.
  BINUTILS_GIT_URL=""

  WITH_GDB_PY=""
  WITH_GDB_PY3=""
  USE_PLATFORM_PYTHON=""
  USE_PLATFORM_PYTHON3=""

  if [ "${WITHOUT_MULTILIB}" == "y" ]
  then
    MULTILIB_FLAGS="--disable-multilib"
  else
    MULTILIB_FLAGS="--with-multilib-list=rmprofile"
  fi

  # Redefine to actual URL if the build should use the Git sources.
  # Also be sure GDB_GIT_BRANCH and GDB_GIT_COMMIT are defined
  GDB_GIT_URL=""
  # Defined for completeness, not yet used by download_gdb().
  GDB_ARCHIVE_URL=""

  GETTEXT_VERSION=""

  NCURSES_VERSION=""
  GPM_VERSION=""

  # ---------------------------------------------------------------------------

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

  # ---------------------------------------------------------------------------

  # No versioning here, the inner archives use simple names.
  BINUTILS_SRC_FOLDER_NAME=${BINUTILS_SRC_FOLDER_NAME:-"binutils"}

  GCC_SRC_FOLDER_NAME=${GCC_SRC_FOLDER_NAME:-"gcc"}
  NEWLIB_SRC_FOLDER_NAME=${NEWLIB_SRC_FOLDER_NAME:-"newlib"}
  GDB_SRC_FOLDER_NAME=${GDB_SRC_FOLDER_NAME:-"gdb"}

  # ---------------------------------------------------------------------------

  # In reverse chronological order.
  # Keep them in sync with combo archive content.
  # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads
  if [[ "${RELEASE_VERSION}" =~ 9\.3\.1-* ]]
  then

    # Used to download the Arm source archive.
    GCC_COMBO_VERSION_MAJOR="9"
    GCC_COMBO_VERSION_YEAR="2020"
    GCC_COMBO_VERSION_QUARTER="q2"
    GCC_COMBO_VERSION_KIND="update"
    GCC_COMBO_VERSION_SUBFOLDER=""

    GCC_COMBO_VERSION="${GCC_COMBO_VERSION_MAJOR}-${GCC_COMBO_VERSION_YEAR}-${GCC_COMBO_VERSION_QUARTER}-${GCC_COMBO_VERSION_KIND}"
    GCC_COMBO_FOLDER_NAME="gcc-arm-none-eabi-${GCC_COMBO_VERSION}"
    GCC_COMBO_ARCHIVE="${GCC_COMBO_FOLDER_NAME}-src.tar.bz2"

    # https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2
    GCC_COMBO_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/${GCC_COMBO_VERSION_MAJOR}-${GCC_COMBO_VERSION_YEAR}${GCC_COMBO_VERSION_QUARTER}${GCC_COMBO_VERSION_SUBFOLDER}/${GCC_COMBO_ARCHIVE}"

    if [[ "${RELEASE_VERSION}" =~ 9\.3\.1-1\.[12] ]]
    then
      README_OUT_FILE_NAME="README-${RELEASE_VERSION}.md"
    fi

    # -------------------------------------------------------------------------
    # Used mainly to name the build folders.

    # From /release.txt
    # binutils-2_34-branch
    # git://sourceware.org/git/binutils-gdb.git commit f75c52135257ea05da151a508d99fbaee1bb9dc1
    BINUTILS_VERSION="2.34"

    # From /release.txt (gcc/BASE_VER). 
    # refs/vendors/ARM/heads/arm-9-branch
    # git://gcc.gnu.org/git/gcc.git commit 13861a80750d118fbdca6006ab175903bacbb7ec
    GCC_VERSION="9.3.1"

    # From /release.txt
    # git://sourceware.org/git/newlib-cygwin.git commit 6d79e0a58866548f435527798fbd4a6849d05bc7
    # VERSION from configure, comment in NEWS.
    NEWLIB_VERSION="3.3.0"

    # From /release.txt
    # git://sourceware.org/git/binutils-gdb.git commit fc94da0a253e925166bbb1a429c190200dc5778d
    GDB_VERSION="8.3"

    # -------------------------------------------------------------------------

    if [[ "${RELEASE_VERSION}" =~ 9\.3\.1-1\.[12] ]]
    then
      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        # On Windows if fails with 
        # "The procedure entry point ClearCommBreak could not be located
        # in the dynamic link library." 
        # It looks like an incompatibility between Python2 and mingw-w64.
        # Given that Python2 is end-of-life, it is not worth to further
        # investigate, disable it for now.
        WITH_GDB_PY2=""
      elif [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        # ImportError: dlopen(/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/lib-dynload/operator.so, 2): Symbol not found: __PyUnicodeUCS2_AsDefaultEncodedString
        #  Referenced from: /Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/lib-dynload/operator.so
        #  Expected in: flat namespace
        # in /Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/lib-dynload/operator.so
        WITH_GDB_PY2=""
      else
        WITH_GDB_PY2="y"
      fi

      PYTHON2_VERSION="2.7.18"

      WITH_GDB_PY3="y" 
      PYTHON3_VERSION="3.7.6"
    else
      WITH_GDB_PY3="y" 
      PYTHON3_VERSION="3.7.9"
    fi

    GDB_PATCH="gdb-${GDB_VERSION}.patch"

    # -------------------------------------------------------------------------

    # Download the combo package from Arm.
    download_gcc_combo

    # -------------------------------------------------------------------------
    # Build dependent libraries.

    # For better control, without it some components pick the lib packed 
    # inside the archive.
    build_zlib "1.2.8"

    # The classical GCC libraries.
    build_gmp "6.1.0"
    build_mpfr "3.1.4"
    build_mpc "1.0.3"
    build_isl "0.18"

    build_libmpdec "2.5.0" # Used by Python
    build_expat "2.1.1"
    build_libiconv "1.15"
    build_xz "5.2.3"

    build_gettext "0.19.8.1"

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      if [ "${WITH_GDB_PY3}" == "y" ]
      then
        if [[ "${RELEASE_VERSION}" =~ 9\.3\.1-1\.[4] ]]
        then
          # Shortcut, use the existing pyton.exe instead of building
          # if from sources. It also downloads the sources.
          download_python3_win "${PYTHON3_VERSION}"

          add_python3_win_syslibs
        fi
      fi
    else # linux or darwin
      # Used by ncurses. Fails on macOS.
      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        build_gpm "1.20.7"
      fi

      build_ncurses "6.2"

      if [[ "${RELEASE_VERSION}" =~ 9\.3\.1-1\.[34] ]]
      then
        build_readline "8.0" # requires ncurses

        build_bzip2 "1.0.8"
        build_libffi "3.3"


        # We cannot rely on a python shared library in the system, even
        # the custom build from sources does not have one.

        if [ "${WITH_GDB_PY3}" == "y" ]
        then
          # Required by a Python 3 module.
          build_sqlite "3.32.3"

          # Replacement for the old libcrypt.so.1; required by Python 3.
          build_libxcrypt "4.4.17"
          build_openssl "1.1.1h"

          build_python3 "${PYTHON3_VERSION}"

          if [[ "${RELEASE_VERSION}" =~ 9\.3\.1-1\.[4] ]]
          then
            add_python3_syslibs
          fi
        fi
      fi
    fi

    # -------------------------------------------------------------------------

    # The task descriptions are from the Arm build script.

    # Task [III-0] /$HOST_NATIVE/binutils/
    # Task [IV-1] /$HOST_MINGW/binutils/

    build_binutils "${BINUTILS_VERSION}"
    # copy_dir to libs included above

    if [ "${TARGET_PLATFORM}" != "win32" ]
    then

      # Task [III-1] /$HOST_NATIVE/gcc-first/
      build_gcc_first

      # Task [III-2] /$HOST_NATIVE/newlib/
      build_newlib ""
      # Task [III-3] /$HOST_NATIVE/newlib-nano/
      build_newlib "-nano"

      # Task [III-4] /$HOST_NATIVE/gcc-final/
      build_gcc_final ""

      # Task [III-5] /$HOST_NATIVE/gcc-size-libstdcxx/
      build_gcc_final "-nano"

    else

      # Task [IV-2] /$HOST_MINGW/copy_libs/
      copy_linux_libs

      # Task [IV-3] /$HOST_MINGW/gcc-final/
      build_gcc_final ""

    fi

    # Task [III-6] /$HOST_NATIVE/gdb/
    # Task [IV-4] /$HOST_MINGW/gdb/
    build_gdb ""

    if [ "${WITH_GDB_PY3}" == "y" ]
    then
      build_gdb "-py3"
    fi

    # Task [III-7] /$HOST_NATIVE/build-manual
    # Nope, the build process is different.

    # -------------------------------------------------------------------------

    # Task [III-8] /$HOST_NATIVE/pretidy/
    # Task [IV-5] /$HOST_MINGW/pretidy/
    tidy_up

    # Task [III-9] /$HOST_NATIVE/strip_host_objects/
    # Task [IV-6] /$HOST_MINGW/strip_host_objects/
    strip_binaries

    # Must be done after gcc 2 make install, otherwise some wrong links
    # are created in libexec.
    # Must also be done after strip binaries, since strip after patchelf
    # damages the binaries.
    prepare_app_folder_libraries

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

    check_binaries

  elif [[ "${RELEASE_VERSION}" =~ 9\.2\.1-* ]]
  then

    # Used to download the Arm source archive.
    GCC_COMBO_VERSION_MAJOR="9"
    GCC_COMBO_VERSION_YEAR="2019"
    GCC_COMBO_VERSION_QUARTER="q4"
    GCC_COMBO_VERSION_KIND="major"
    GCC_COMBO_VERSION_SUBFOLDER=""

    GCC_COMBO_VERSION="${GCC_COMBO_VERSION_MAJOR}-${GCC_COMBO_VERSION_YEAR}-${GCC_COMBO_VERSION_QUARTER}-${GCC_COMBO_VERSION_KIND}"
    GCC_COMBO_FOLDER_NAME="gcc-arm-none-eabi-${GCC_COMBO_VERSION}"
    GCC_COMBO_ARCHIVE="${GCC_COMBO_FOLDER_NAME}-src.tar.bz2"

    # https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-src.tar.bz2
    GCC_COMBO_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/${GCC_COMBO_VERSION_MAJOR}-${GCC_COMBO_VERSION_YEAR}${GCC_COMBO_VERSION_QUARTER}${GCC_COMBO_VERSION_SUBFOLDER}/${GCC_COMBO_ARCHIVE}"

    README_OUT_FILE_NAME="README-${RELEASE_VERSION}.md"

    # -------------------------------------------------------------------------
    # Used mainly to name the build folders.

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

    # -------------------------------------------------------------------------

    # Arm uses 2.7.7
    PYTHON2_VERSION="2.7.13" # -> 2.7.17

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

    if [ "${RELEASE_VERSION}" != "9.2.1-1.1" ]
    then
      # 9.2.1-1.2 and up

      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        USE_PLATFORM_PYTHON="n"
        USE_PLATFORM_PYTHON3="n"
      fi
      GDB_PATCH="gdb-${GDB_VERSION}.patch"
      USE_SINGLE_FOLDER_PATH="y"

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        WITH_GDB_PY="n"
      fi

      # https://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=commit;h=272044897e178835f596c96740c5a1800ec6f9fb
      WITH_GDB_PY3="y" 
      PYTHON3_VERSION="3.7.6"
    fi

    # -------------------------------------------------------------------------

    # Download the combo package from Arm.
    download_gcc_combo

    # -------------------------------------------------------------------------
    # Build dependent libraries.

    # For better control, without it some components pick the lib packed 
    # inside the archive.
    build_zlib "1.2.8"

    # The classical GCC libraries.
    build_gmp "6.1.0"
    build_mpfr "3.1.4"
    build_mpc "1.0.3"
    build_isl "0.18"

    build_expat "2.1.1"

    # LIBELF_VERSION="0.8.13"

    if [ "${TARGET_PLATFORM}" == "darwin" ]
    then
      build_libiconv "1.15"
    fi

    build_xz "5.2.3"

    build_gettext "0.19.8.1"

    if [ "${TARGET_PLATFORM}" != "win32" ]
    then
      # Used by ncurses. Fais on macOS.
      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        build_gpm "1.20.7"
      fi

      build_ncurses "6.2"
    fi


    # -------------------------------------------------------------------------

    # The task descriptions are from the Arm build script.

    # Task [III-0] /$HOST_NATIVE/binutils/
    # Task [IV-1] /$HOST_MINGW/binutils/

    build_binutils "${BINUTILS_VERSION}"
    # copy_dir to libs included above

    if [ "${TARGET_PLATFORM}" != "win32" ]
    then

      # Task [III-1] /$HOST_NATIVE/gcc-first/
      build_gcc_first

      # Task [III-2] /$HOST_NATIVE/newlib/
      build_newlib ""
      # Task [III-3] /$HOST_NATIVE/newlib-nano/
      build_newlib "-nano"

      # Task [III-4] /$HOST_NATIVE/gcc-final/
      build_gcc_final ""

      # Task [III-5] /$HOST_NATIVE/gcc-size-libstdcxx/
      build_gcc_final "-nano"

    else

      # Task [IV-2] /$HOST_MINGW/copy_libs/
      copy_linux_libs

      # Task [IV-3] /$HOST_MINGW/gcc-final/
      build_gcc_final ""

    fi

    # Task [III-6] /$HOST_NATIVE/gdb/
    # Task [IV-4] /$HOST_MINGW/gdb/
    build_gdb ""

    if [ "${WITH_GDB_PY}" == "y" ]
    then
      # The Windows GDB needs some headers from the Python distribution.
      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        download_python2_win "${PYTHON2_VERSION}"
      fi

      build_gdb "-py"
    fi

    if [ "${WITH_GDB_PY3}" == "y" ]
    then
      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        download_python3_win "${PYTHON3_VERSION}"
      fi

      build_gdb "-py3"
    fi

if false
then
    # Task [III-7] /$HOST_NATIVE/build-manual
    # Nope, the build process is different.

    # -------------------------------------------------------------------------

    # Task [III-8] /$HOST_NATIVE/pretidy/
    # Task [IV-5] /$HOST_MINGW/pretidy/
    tidy_up

    # Task [III-9] /$HOST_NATIVE/strip_host_objects/
    # Task [IV-6] /$HOST_MINGW/strip_host_objects/
    strip_binaries

    # Must be done after gcc 2 make install, otherwise some wrong links
    # are created in libexec.
    # Must also be done after strip binaries, since strip after patchelf
    # damages the binaries.
    prepare_app_folder_libraries

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

    check_binaries
fi
  else
    echo "Unsupported version ${RELEASE_VERSION}."
    exit 1
  fi

  # ---------------------------------------------------------------------------
}

# -----------------------------------------------------------------------------
