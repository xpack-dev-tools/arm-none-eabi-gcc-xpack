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

# Script to build the xPack GNU Arm Embeded GCC distribution packages.
#
# Developed on macOS 10.13 High Sierra, but intended to run on
# macOS 10.10 Yosemite and CentOS 6 XBB. 

# -----------------------------------------------------------------------------

echo
echo "xPack GNU Arm Embedded GCC distribution build script."

host_functions_script_path="${script_folder_path}/helper/host-functions-source.sh"
echo
echo "Host helper functions source script: \"${host_functions_script_path}\"."
source "${host_functions_script_path}"

common_functions_script_path="${script_folder_path}/common-functions-source.sh"
echo "Common functions source script: \"${common_functions_script_path}\"."
source "${common_functions_script_path}"

defines_script_path="${script_folder_path}/defs-source.sh"
echo "Definitions source script: \"${defines_script_path}\"."
source "${defines_script_path}"

host_detect

# docker_linux64_image="ilegeul/centos:6-xbb-v2"
# docker_linux32_image="ilegeul/centos32:6-xbb-v2"

# -----------------------------------------------------------------------------

# Array where the remaining args will be stored.
declare -a rest

help_message="    bash $0 [--win32] [--win64] [--linux32] [--linux64] [--osx] [--all] [clean|cleanlibs|cleanall|preload-images] [--env-file file] [--disable-strip] [--without-pdf] [--with-html] [--disable-multilib] [--develop] [--debug] [--use-gits] [--jobs N] [--help]"
host_options "${help_message}" $@

host_common

# -----------------------------------------------------------------------------

if [ -n "${DO_BUILD_WIN32}${DO_BUILD_WIN64}${DO_BUILD_LINUX32}${DO_BUILD_LINUX64}" ]
then
  host_prepare_docker
fi

# ----- Build the native distribution. ----------------------------------------

if [ -z "${DO_BUILD_OSX}${DO_BUILD_LINUX64}${DO_BUILD_WIN64}${DO_BUILD_LINUX32}${DO_BUILD_WIN32}" ]
then

  host_build_target "Creating the native distribution..." \
    --script "${HOST_WORK_FOLDER_PATH}/${CONTAINER_BUILD_SCRIPT_REL_PATH}" \
    --env-file "${ENV_FILE}" \
    -- \
    ${rest[@]-}

else

  # ----- Build the OS X distribution. ----------------------------------------

  if [ "${DO_BUILD_OSX}" == "y" ]
  then
    if [ "${HOST_UNAME}" == "Darwin" ]
    then
      host_build_target "Creating the OS X distribution..." \
        --script "${HOST_WORK_FOLDER_PATH}/${CONTAINER_BUILD_SCRIPT_REL_PATH}" \
        --env-file "${ENV_FILE}" \
        --target-platform "darwin" \
        -- \
        ${rest[@]-}
    else
      echo "Building the macOS image is not possible on this platform."
      exit 1
    fi
  fi

  # ----- Build the GNU/Linux 64-bit distribution. ---------------------------

  if [ "${DO_BUILD_LINUX64}" == "y" ]
  then
    host_build_target "Creating the GNU/Linux 64-bit distribution..." \
      --script "${CONTAINER_WORK_FOLDER_PATH}/${CONTAINER_BUILD_SCRIPT_REL_PATH}" \
      --env-file "${ENV_FILE}" \
      --target-platform "linux" \
      --target-arch "x64" \
      --target-bits 64 \
      --docker-image "${docker_linux64_image}" \
      -- \
      ${rest[@]-}
  fi

  # ----- Build the Windows 64-bit distribution. -----------------------------

  if [ "${DO_BUILD_WIN64}" == "y" ]
  then
    linux_install_relative_path="linux-x64/install/${APP_LC_NAME}"
    if [ ! -f "${HOST_WORK_FOLDER_PATH}/${linux_install_relative_path}/bin/${GCC_TARGET}-gcc" ]
    then
      host_build_target "Creating the GNU/Linux 64-bit distribution..." \
        --script "${CONTAINER_WORK_FOLDER_PATH}/${CONTAINER_BUILD_SCRIPT_REL_PATH}" \
        --env-file "${ENV_FILE}" \
        --target-platform "linux" \
        --target-arch "x64" \
        --target-bits 64 \
        --docker-image "${docker_linux64_image}" \
        -- \
        ${rest[@]-}
    fi

    if [ ! -f "${HOST_WORK_FOLDER_PATH}/${linux_install_relative_path}/bin/${GCC_TARGET}-gcc" ]
    then
      echo "Mandatory GNU/Linux binaries missing."
      exit 1
    fi

    host_build_target "Creating the Windows 64-bit distribution..." \
      --script "${CONTAINER_WORK_FOLDER_PATH}/${CONTAINER_BUILD_SCRIPT_REL_PATH}" \
      --env-file "${ENV_FILE}" \
      --target-platform "win32" \
      --target-arch "x64" \
      --target-bits 64 \
      --docker-image "${docker_linux64_image}" \
      -- \
      --linux-install-path "${linux_install_relative_path}" \
      ${rest[@]-}
  fi

  # ----- Build the GNU/Linux 32-bit distribution. ---------------------------

  if [ "${DO_BUILD_LINUX32}" == "y" ]
  then
    host_build_target "Creating the GNU/Linux 32-bit distribution..." \
      --script "${CONTAINER_WORK_FOLDER_PATH}/${CONTAINER_BUILD_SCRIPT_REL_PATH}" \
      --env-file "${ENV_FILE}" \
      --target-platform "linux" \
      --target-arch "x32" \
      --target-bits 32 \
      --docker-image "${docker_linux32_image}" \
      -- \
      ${rest[@]-}
  fi

  # ----- Build the Windows 32-bit distribution. -----------------------------

  # Since the actual container is a 32-bit, use the debian32 binaries.
  if [ "${DO_BUILD_WIN32}" == "y" ]
  then
    linux_install_relative_path="linux-x32/install/${APP_LC_NAME}"
    if [ ! -f "${HOST_WORK_FOLDER_PATH}/${linux_install_relative_path}/bin/${GCC_TARGET}-gcc" ]
    then
      host_build_target "Creating the GNU/Linux 32-bit distribution..." \
        --script "${CONTAINER_WORK_FOLDER_PATH}/${CONTAINER_BUILD_SCRIPT_REL_PATH}" \
        --env-file "${ENV_FILE}" \
        --target-platform "linux" \
        --target-arch "x32" \
        --target-bits 32 \
        --docker-image "${docker_linux32_image}" \
        -- \
        ${rest[@]-}
    fi

    if [ ! -f "${HOST_WORK_FOLDER_PATH}/${linux_install_relative_path}/bin/${GCC_TARGET}-gcc" ]
    then
      echo "Mandatory GNU/Linux binaries missing."
      exit 1
    fi

    host_build_target "Creating the Windows 32-bit distribution..." \
      --script "${CONTAINER_WORK_FOLDER_PATH}/${CONTAINER_BUILD_SCRIPT_REL_PATH}" \
      --env-file "${ENV_FILE}" \
      --target-platform "win32" \
      --target-arch "x32" \
      --target-bits 32 \
      --docker-image "${docker_linux32_image}" \
      -- \
      --linux-install-path "${linux_install_relative_path}" \
      ${rest[@]-}
  fi

fi

host_show_sha

# -----------------------------------------------------------------------------

host_stop_timer

host_notify_completed

# Completed successfully.
exit 0

# -----------------------------------------------------------------------------
