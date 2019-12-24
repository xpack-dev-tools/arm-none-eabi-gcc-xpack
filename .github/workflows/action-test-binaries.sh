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

function run_binutils()
{
  echo
  echo "Testing if binutils start properly..."

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
}

function run_gcc()
{
  echo
  echo "Testing if gcc starts properly..."

  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" --help
  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" -dumpversion
  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" -dumpmachine
  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" -print-multi-lib
  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" -dumpspecs | wc -l
 
  echo
  echo "Testing if gcc compiles simple programs..."

  local tmp=$(mktemp /tmp/gcc-test.XXXXX)
  rm -rf "${tmp}"

  mkdir -p "${tmp}"
  cd "${tmp}"

  # Note: __EOF__ is quoted to prevent substitutions here.
  cat <<'__EOF__' > hello.c
#include <stdio.h>

int
main(int argc, char* argv[])
{
  printf("Hello World\n");
}
__EOF__

  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" -o hello-c.elf -specs=nosys.specs hello.c

  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" -o hello.c.o -c -flto hello.c
  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" -o hello-c-lto.elf -specs=nosys.specs -flto -v hello.c.o

  # Note: __EOF__ is quoted to prevent substitutions here.
  cat <<'__EOF__' > hello.cpp
#include <iostream>

int
main(int argc, char* argv[])
{
  std::cout << "Hello World" << std::endl;
}

extern "C" void __sync_synchronize();

void 
__sync_synchronize()
{
}
__EOF__

  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-g++" -o hello-cpp.elf -specs=nosys.specs hello.cpp

  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-g++" -o hello.cpp.o -c -flto hello.cpp
  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-g++" -o hello-cpp-lto.elf -specs=nosys.specs -flto -v hello.cpp.o

  cd ..
  rm -rf "${tmp}"
}

function run_gdb()
{
  local suffix=""
  if [ $# -ge 1 ]
  then
    suffix="$1"
  fi

  # error while loading shared libraries: /Host/home/ilg/Work/arm-none-eabi-gcc-8.2.1-1.5/linux-x32/install/arm-none-eabi-gcc/bin/libpython3.7m.so.1.0: unsupported version 0 of Verneed record
  # if [ "${suffix}" == "-py3" -a "${TARGET_PLATFORM}" == "linux" -a "${TARGET_ARCH}" == "x32" ]
  # then
  #   return 0
  # fi

  echo
  echo "Testing if gdb${suffix} starts properly..."

  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gdb${suffix}" --version
  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gdb${suffix}" --config

  # This command is known to fail with 'Abort trap: 6' (SIGABRT)
  run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gdb${suffix}" \
    --nh \
    --nx \
    -ex='show language' \
    -ex='set language auto' \
    -ex='quit'
}

# =============================================================================

mkdir -p $HOME/test
cd $HOME/test

APP_PREFIX=xpack-arm-none-eabi-gcc-9.2.1-1.1
GCC_TARGET=arm-none-eabi

echo
echo "Downloading ${APP_PREFIX}-linux-x64.tar.gz..."
curl -L --fail -o ${APP_PREFIX}-linux-x64.tar.gz \
  https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v9.2.1-1.1/${APP_PREFIX}-linux-x64.tar.gz

echo "Extracting ${APP_PREFIX}-linux-x64.tar.gz..."
tar xf ${APP_PREFIX}-linux-x64.tar.gz

TARGET_PLATFORM=linux
TARGET_ARCH=x64

# -----------------------------------------------------------------------------

run_binutils

run_gcc

run_gdb
run_gdb "-py"
run_gdb "-py3"

echo
echo "Done."

exit 0

# -----------------------------------------------------------------------------
