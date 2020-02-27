#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Identify the script location, to reach, for example, the helper scripts.

build_script_path="$0"
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path="$(pwd)/$0"
fi

script_folder_path="$(dirname "${build_script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

# Script to build a native xPack GNU Arm Embedded GCC, which uses the
# tools and libraries available on the host machine. It is generally
# intended for development and creating customised versions (as opposed
# to the build intended for creating distribution packages).
#
# Developed on Ubuntu 16 LTS x64 and macOS 10.14. 

# Credits: GNU Tools for Arm Embedded Processors, version 7, by Arm.

# -----------------------------------------------------------------------------

echo
echo "xPack GNU Arm Embedded GCC distribution build script."

echo
host_functions_script_path="${script_folder_path}/helper/host-functions-source.sh"
echo "Host helper functions source script: \"${host_functions_script_path}\"."
source "${host_functions_script_path}"

common_functions_script_path="${script_folder_path}/common-functions-source.sh"
echo "Common functions source script: \"${common_functions_script_path}\"."
source "${common_functions_script_path}"

common_versions_script_path="${script_folder_path}/common-versions-source.sh"
echo "Common versions source script: \"${common_versions_script_path}\"."
source "${common_versions_script_path}"

defines_script_path="${script_folder_path}/defs-source.sh"
echo "Definitions source script: \"${defines_script_path}\"."
source "${defines_script_path}"

host_detect

docker_images

# -----------------------------------------------------------------------------

help_message="    bash $0 [--win] [--disable-multilib] [--disable-strip] [--without-pdf] [--with-html] [--debug] [--develop] [--jobs N] [--help] [clean|cleanlibs|cleanall]"
host_custom_options "${help_message}" $@

# -----------------------------------------------------------------------------

host_common

prepare_xbb_env
prepare_xbb_extras

# -----------------------------------------------------------------------------

container_libs_functions_script_path="${script_folder_path}/${CONTAINER_LIBS_FUNCTIONS_SCRIPT_NAME}"
echo "Container lib functions source script: \"${container_libs_functions_script_path}\"."
source "${container_libs_functions_script_path}"

container_apps_functions_script_path="${script_folder_path}/${CONTAINER_APPS_FUNCTIONS_SCRIPT_NAME}"
echo "Container app functions source script: \"${container_apps_functions_script_path}\"."
source "${container_apps_functions_script_path}"

# -----------------------------------------------------------------------------

prepare_versions

# -----------------------------------------------------------------------------

echo
echo "Here we go..."
echo

# Download the combo package from Arm.
download_gcc_combo

if [ "${TARGET_PLATFORM}" == "win32" ]
then
  # The Windows GDB needs some headers from the Python distribution.
  if [ "${WITH_GDB_PY}" == "y" ]
  then
    download_python_win
  fi
  
  if [ "${WITH_GDB_PY3}" == "y" ]
  then
    download_python3_win
  fi
fi

# -----------------------------------------------------------------------------
# Build dependent libraries.

# For better control, without it some components pick the lib packed 
# inside the archive.
do_zlib

# The classical GCC libraries.
do_gmp
do_mpfr
do_mpc
do_isl

# More libraries.
do_libelf
do_expat
do_libiconv
do_xz

if [ ! -z "${GETTEXT_VERSION}" ]
then
  do_gettext
fi

# -----------------------------------------------------------------------------

# The task descriptions are from the Arm build script.

# Task [III-0] /$HOST_NATIVE/binutils/
# Task [IV-1] /$HOST_MINGW/binutils/
do_binutils
# copy_dir to libs included above

if [ "${TARGET_PLATFORM}" != "win32" ]
then

  # Task [III-1] /$HOST_NATIVE/gcc-first/
  do_gcc_first

  # Task [III-2] /$HOST_NATIVE/newlib/
  do_newlib ""
  # Task [III-3] /$HOST_NATIVE/newlib-nano/
  do_newlib "-nano"

  # Task [III-4] /$HOST_NATIVE/gcc-final/
  do_gcc_final ""

  # Task [III-5] /$HOST_NATIVE/gcc-size-libstdcxx/
  do_gcc_final "-nano"

else

  # Task [IV-2] /$HOST_MINGW/copy_libs/
  copy_linux_libs

  # Task [IV-3] /$HOST_MINGW/gcc-final/
  do_gcc_final ""

fi

# Task [III-6] /$HOST_NATIVE/gdb/
# Task [IV-4] /$HOST_MINGW/gdb/
do_gdb ""

if [ "${WITH_GDB_PY}" == "y" ]
then
  do_gdb "-py"
fi

if [ "${WITH_GDB_PY3}" == "y" ]
then
  do_gdb "-py3"
fi

# Task [III-7] /$HOST_NATIVE/build-manual
# Nope, the build process is different.

# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------

check_binaries

copy_distro_files

create_archive

# Change ownership to non-root Linux user.
# fix_ownership

# -----------------------------------------------------------------------------

# Final checks.
# To keep everything as pristine as possible, run tests
# only after the archive is packed.
run_binutils
run_gcc
run_gdb

if [  "${TARGET_PLATFORM}" != "win32" ]
then
  if [ "${WITH_GDB_PY}" == "y" ]
  then
    run_gdb "-py"
  fi

  if [ "${WITH_GDB_PY3}" == "y" ]
  then
    run_gdb "-py3"
  fi
fi

# -----------------------------------------------------------------------------

host_stop_timer

exit 0

# -----------------------------------------------------------------------------
