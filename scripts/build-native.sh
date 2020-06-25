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

common_helper_functions_script_path="${script_folder_path}/helper/common-functions-source.sh"
echo "Common helper functions source script: \"${common_helper_functions_script_path}\"."
source "${common_helper_functions_script_path}"

common_helper_libs_functions_script_path="${script_folder_path}/helper/common-libs-functions-source.sh"
echo "Common helper libs functions source script: \"${common_helper_libs_functions_script_path}\"."
source "${common_helper_libs_functions_script_path}"

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
host_custom_options "${help_message}" "$@"

# -----------------------------------------------------------------------------

host_common

prepare_xbb_env
prepare_xbb_extras

tests_initialize

# -----------------------------------------------------------------------------

container_libs_functions_script_path="${script_folder_path}/${CONTAINER_LIBS_FUNCTIONS_SCRIPT_NAME}"
echo "Container lib functions source script: \"${container_libs_functions_script_path}\"."
source "${container_libs_functions_script_path}"

container_apps_functions_script_path="${script_folder_path}/${CONTAINER_APPS_FUNCTIONS_SCRIPT_NAME}"
echo "Container app functions source script: \"${container_apps_functions_script_path}\"."
source "${container_apps_functions_script_path}"

# -----------------------------------------------------------------------------

echo
echo "Here we go..."
echo

build_versions

# -----------------------------------------------------------------------------

build_versions

# -----------------------------------------------------------------------------

copy_distro_files

create_archive

# Change ownership to non-root Linux user.
# fix_ownership

# -----------------------------------------------------------------------------

# Final checks.
# To keep everything as pristine as possible, run tests
# only after the archive is packed.

prime_wine

tests_run

# -----------------------------------------------------------------------------

host_stop_timer

exit 0

# -----------------------------------------------------------------------------
