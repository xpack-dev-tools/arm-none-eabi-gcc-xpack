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

function validate()
{
  host_platform=$(uname -s | tr '[:upper:]' '[:lower:]')
  host_machine=$(uname -m | tr '[:upper:]' '[:lower:]')
  # echo ${host_platform} ${host_machine}

  if [ "${host_platform}" != "${archive_platform}" ]
  then
    echo "The ${archive_name} can only be tested on ${archive_platform}, not ${host_platform}."
    exit 1
  fi

  case "${archive_platform}" in
    linux)
      case "${archive_arch}" in
        x64)
          if [ "${host_machine}" != "x86_64" ]
          then
            echo "Testing ${archive_arch} not supported on ${host_machine}."
            exit 1
          fi
          ;;
        x32)
          if [ "${host_machine}" != "i386" -a "${host_machine}" != "x86_64" ]
          then
            echo "Testing ${archive_arch} not supported on ${host_machine}."
            exit 1
          fi
          ;;
        arm64)
          if [ "${host_machine}" != "aarch64" ]
          then
            echo "Testing ${archive_arch} not supported on ${host_machine}."
            exit 1
          fi
          ;;
        arm)
          if [ "${host_machine}" != "armv7l" -a "${host_machine}" != "armv8l" -a "${host_machine}" != "aarch64" ]
          then
            echo "Testing ${archive_arch} not supported on ${host_machine}."
            exit 1
          fi
          ;;
        *)
          echo "Testing ${archive_arch} not supported."
          exit 1
          ;;
      esac
      ;;
    darwin)
      case "${archive_arch}" in
        x64)
          ;;
        *)
          echo "Testing ${archive_arch} not supported."
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Testing ${archive_platform} not supported."
      exit 1
      ;;
  esac
}

function run_app()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  echo
  echo "${app_path} $@"
  "${app_path}" $@ 2>&1
}

function run_binutils()
{
  echo
  echo "Testing if binutils start properly..."

  run_app "${app_absolute_path}/bin/${gcc_target}-ar" --version
  run_app "${app_absolute_path}/bin/${gcc_target}-as" --version
  run_app "${app_absolute_path}/bin/${gcc_target}-ld" --version
  run_app "${app_absolute_path}/bin/${gcc_target}-nm" --version
  run_app "${app_absolute_path}/bin/${gcc_target}-objcopy" --version
  run_app "${app_absolute_path}/bin/${gcc_target}-objdump" --version
  run_app "${app_absolute_path}/bin/${gcc_target}-ranlib" --version
  run_app "${app_absolute_path}/bin/${gcc_target}-size" --version
  run_app "${app_absolute_path}/bin/${gcc_target}-strings" --version
  run_app "${app_absolute_path}/bin/${gcc_target}-strip" --version
}

function run_gcc()
{
  echo
  echo "Testing if gcc starts properly..."

  run_app "${app_absolute_path}/bin/${gcc_target}-gcc" --help
  run_app "${app_absolute_path}/bin/${gcc_target}-gcc" -dumpversion
  run_app "${app_absolute_path}/bin/${gcc_target}-gcc" -dumpmachine
  run_app "${app_absolute_path}/bin/${gcc_target}-gcc" -print-multi-lib
  run_app "${app_absolute_path}/bin/${gcc_target}-gcc" -dumpspecs | wc -l
 
  echo
  echo "Testing if gcc compiles simple programs..."

  local tmp="${test_absolute_path}-gcc"
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

  run_app "${app_absolute_path}/bin/${gcc_target}-gcc" -o hello-c.elf -specs=nosys.specs hello.c

  run_app "${app_absolute_path}/bin/${gcc_target}-gcc" -o hello.c.o -c -flto hello.c
  run_app "${app_absolute_path}/bin/${gcc_target}-gcc" -o hello-c-lto.elf -specs=nosys.specs -flto -v hello.c.o

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

  run_app "${app_absolute_path}/bin/${gcc_target}-g++" -o hello-cpp.elf -specs=nosys.specs hello.cpp

  run_app "${app_absolute_path}/bin/${gcc_target}-g++" -o hello.cpp.o -c -flto hello.cpp
  run_app "${app_absolute_path}/bin/${gcc_target}-g++" -o hello-cpp-lto.elf -specs=nosys.specs -flto -v hello.cpp.o

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

  (
    echo
    echo "Testing if gdb${suffix} starts properly..."

    case "${suffix}" in
      '')
        ;;
      -py)
        echo
        python2.7 --version
        python2.7 -c 'import sys; print sys.path'

        export PYTHONHOME="$(python2.7 -c 'from distutils import sysconfig;print(sysconfig.PREFIX)')"
        echo "PYTHONHOME=${PYTHONHOME}"
        ;;
      -py3)
        echo
        python3.7 --version
        python3.7 -c 'import sys; print(sys.path)'

        export PYTHONHOME="$(python3.7 -c 'from distutils import sysconfig;print(sysconfig.PREFIX)')"
        echo "PYTHONHOME=${PYTHONHOME}"
        ;;
      *)
        echo "Unsupported gdb-${suffix}"
        exit 1
        ;;
    esac

    echo
    run_app "${app_absolute_path}/bin/${gcc_target}-gdb${suffix}" --version
    run_app "${app_absolute_path}/bin/${gcc_target}-gdb${suffix}" --config

    # This command is known to fail with 'Abort trap: 6' (SIGABRT)
    run_app "${app_absolute_path}/bin/${gcc_target}-gdb${suffix}" \
      --nh \
      --nx \
      -ex='show language' \
      -ex='set language auto' \
      -ex='quit'
  )
}

# =============================================================================

if [ $# -lt 1 ]
then
  echo "Usage: bash tests/scripts/test-binaries.sh [--skip-gdb-py] [--skip-gdb-py3] <archive-url>"
  echo "Archive name is like: xpack-arm-none-eabi-gcc-9.2.1-1.1-linux-x64.tar.gz"
  exit 1
fi

has_gdb_py="y"
has_gdb_py3="y"

while [ $# -gt 0 ]
do
  case "$1" in

    --skip-gdb-py)
      has_gdb_py="n"
      shift
      ;;

    --skip-gdb-py3)
      has_gdb_py3="n"
      shift
      ;;

    -*)
      echo "Unsupported option $1."
      exit 1
      ;;

    *)
      url=$1
      shift
      ;;

  esac
done


archive_name=$(basename ${url})
# echo ${archive_name}

gcc_target=arm-none-eabi

archive_folder_name=$(echo ${archive_name} | sed -e "s/\(xpack-${gcc_target}-gcc-[0-9.]*-[0-9.]*\)-.*/\1/")
archive_platform=$(echo ${archive_name} | sed -e "s/\(xpack-${gcc_target}-gcc-[0-9.]*-[0-9.]*\)-\([a-z]*\)-.*/\2/")
archive_arch=$(echo ${archive_name} | sed -e "s/\(xpack-${gcc_target}-gcc-[0-9.]*-[0-9.]*\)-\([a-z]*\)-\([a-z0-9]*\).*/\3/")
# echo ${archive_folder_name} ${archive_platform} ${archive_arch}

validate

echo
echo "Test the ${archive_name} binaries on ${host_platform} ${host_machine}."

work_absolute_path="${HOME}/Work"
cache_absolute_path="${work_absolute_path}/cache"
mkdir -p "${work_absolute_path}/cache"
cd "${work_absolute_path}/cache"

if [ ! -f "${archive_name}" ]
then
  echo
  echo "Downloading ${archive_name}..."
  curl -L --fail -o "${archive_name}" ${url}
fi

test_absolute_path="${work_absolute_path}/test-arm-none-eabi-gcc"

rm -rf "${test_absolute_path}"
mkdir -p "${test_absolute_path}"
cd "${test_absolute_path}"

echo
echo "Extracting ${archive_name}..."
tar xf "${work_absolute_path}/cache/${archive_name}"

ls -lL "${test_absolute_path}"/xpack-arm-none-eabi-gcc*

TARGET_PLATFORM=${archive_platform}
TARGET_ARCH=${archive_arch}

# -----------------------------------------------------------------------------

app_absolute_path="${test_absolute_path}/${archive_folder_name}"

run_binutils

run_gcc

run_gdb

if [ "${has_gdb_py}" == "y" ]
then
  run_gdb "-py"
fi

if [ "${has_gdb_py3}" == "y" ]
then
  run_gdb "-py3"
fi

echo
echo "Done."

exit 0

# -----------------------------------------------------------------------------
