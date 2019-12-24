#!/usr/bin/env bash

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

script_path="$0"
if [[ "${script_path}" != /* ]]
then
  # Make relative path absolute.
  script_path="$(pwd)/$0"
fi

script_name="$(basename "${script_path}")"

script_folder_path="$(dirname "${script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

function run_app()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  echo
  echo "${app_path} $@"
  "${app_path}" $@
}

# =============================================================================

mkdir -p $HOME/test
cd $HOME/test

APP_PREFIX=xpack-arm-none-eabi-gcc-9.2.1-1.1
GCC_TARGET=arm-none-eabi

curl -L --fail -o ${APP_PREFIX}-linux-x64.tar.gz \
https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v9.2.1-1.1/${${APP_PREFIX}}-linux-x64.tar.gz
tar xf ${APP_PREFIX}-linux-x64.tar.gz

APP_PREFIX=xpack-arm-none-eabi-gcc-9.2.1-1.1
GCC_TARGET=arm-none-eabi

# Test if binutils start properly.
run_app "${APP_PREFIX}/bin/${GCC_TARGET}-ar" --version
run_app "${APP_PREFIX}/bin/${GCC_TARGET}-as" --version
run_app "${APP_PREFIX}/bin/${GCC_TARGET}-ld" --version
run_app "${APP_PREFIX}/bin/${GCC_TARGET}-nm" --version
run_app "${APP_PREFIX}/bin/${GCC_TARGET}-objcopy" --version
run_app "${APP_PREFIX}/bin/${GCC_TARGET}-objdump" --version
run_app "${APP_PREFIX}/bin/${GCC_TARGET}-ranlib" --version
run_app "${APP_PREFIX}/bin/${GCC_TARGET}-size" --version
run_app "${APP_PREFIX}/bin/${GCC_TARGET}-strings" --version
run_app "${APP_PREFIX}/bin/${GCC_TARGET}-strip" --version

exit 0

# -----------------------------------------------------------------------------
