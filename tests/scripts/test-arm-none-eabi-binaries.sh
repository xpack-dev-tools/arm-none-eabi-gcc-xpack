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

  if [ "${host_platform}" != "${archive_platform}" ] && [[ "${host_platform}" != mingw64_nt* ]]
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
          if [ "${host_machine}" != "i386" -a "${host_machine}" != "i586" -a "${host_machine}" != "i686" -a "${host_machine}" != "x86_64" ]
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
    win32)
      case "${archive_arch}" in
        x64)
          if [ "${host_machine}" != "x86_64" ]
          then
            echo "Testing ${archive_arch} not supported on ${host_machine}."
            exit 1
          fi
          ;;
        x32)
          if [ "${host_machine}" != "i386" -a "${host_machine}" != "i586" -a "${host_machine}" != "i686" -a "${host_machine}" != "x86_64" ]
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
    *)
      echo "Testing ${archive_platform} not supported."
      exit 1
      ;;
  esac
}

function show_libs()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift
  if [ "${archive_platform}" == "win32" ]
  then
    app_path+='.exe'
  fi

  echo
  echo "ldd ${app_path}"
  ldd "${app_path}" 2>&1
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

  show_libs "${app_absolute_path}/bin/${gcc_target}-ar"
  show_libs "${app_absolute_path}/bin/${gcc_target}-as"
  show_libs "${app_absolute_path}/bin/${gcc_target}-ld"
  show_libs "${app_absolute_path}/bin/${gcc_target}-nm"
  show_libs "${app_absolute_path}/bin/${gcc_target}-objcopy"
  show_libs "${app_absolute_path}/bin/${gcc_target}-objdump"
  show_libs "${app_absolute_path}/bin/${gcc_target}-ranlib"
  show_libs "${app_absolute_path}/bin/${gcc_target}-size"
  show_libs "${app_absolute_path}/bin/${gcc_target}-strings"
  show_libs "${app_absolute_path}/bin/${gcc_target}-strip"

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

  show_libs "${app_absolute_path}/bin/${gcc_target}-gcc"
  show_libs "${app_absolute_path}/bin/${gcc_target}-g++"

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

  local exe=""
  if [ "${archive_platform}" == "win32" ]
  then
    exe=".exe"
  fi

  if [ ! -x "${app_absolute_path}/bin/${gcc_target}-gdb${suffix}${exe}" ]
  then
    echo
    echo ">>> gdb${suffix} not present, skipping..."
    return
  fi

  (
    case "${suffix}" in
      '')
        echo
        echo "Testing if gdb${suffix} starts properly..."
        ;;
      -py)
        local python_name
        if [ "${archive_platform}" == "win32" ]
        then
          python_name="python"
        else       
          python_name="python2.7"
        fi

        local which_python
        set +e
        which_python="$(which ${python_name} 2>/dev/null)"
        if [ -z "${which_python}" ]
        then
          echo
          echo ">>> No ${python_name} installed, skipping gdb_py test."
          return
        fi
        set -e
        echo
        echo "Testing if gdb${suffix} starts properly..."
        echo
        ${python_name} --version
        ${python_name} -c 'import sys; print sys.path'

        export PYTHONHOME="$(${python_name} -c 'from distutils import sysconfig;print(sysconfig.PREFIX)')"
        echo "PYTHONHOME=${PYTHONHOME}"
        ;;
      -py3)
        local python_name
        if [ "${archive_platform}" == "win32" ]
        then
          python_name="python"
        else       
          python_name="python3.7"
        fi

        set +e
        local which_python
        which_python="$(which ${python_name} 2>/dev/null)"
        if [ -z "${which_python}" ]
        then
          echo
          echo ">>> No python3.7 installed, skipping gdb_py3 test."
          return
        fi
        set -e

        echo
        echo "Testing if gdb${suffix} starts properly..."
        echo
        ${python_name} --version
        ${python_name} -c 'import sys; print(sys.path)'

        export PYTHONHOME="$(${python_name} -c 'from distutils import sysconfig;print(sysconfig.PREFIX)')"
        echo "PYTHONHOME=${PYTHONHOME}"
        ;;

      *)
        echo "Unsupported gdb-${suffix}"
        exit 1
        ;;
    esac

    # rm -rf "${app_absolute_path}/bin/python27.dll"
    show_libs "${app_absolute_path}/bin/${gcc_target}-gdb${suffix}"

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
    
    if [ ! -z "${suffix}" ]
    then
      local out=$("${app_absolute_path}/bin/${gcc_target}-gdb${suffix}" \
        --nh \
        --nx \
        -ex='python print("baburiba")' \
        -ex='quit' | grep 'baburiba')
      if [ "${out}" == "baburiba" ]
      then
        echo
        echo 'GDB python print() functional.'
      else
        echo
        echo 'GDB python print() not functional.'
        exit 1
      fi
    fi
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
archive_platform=$(echo ${archive_name} | sed -e "s/\(xpack-${gcc_target}-gcc-[0-9.]*-[0-9.]*\)-\([a-z0-9]*\)-.*/\2/")
archive_arch=$(echo ${archive_name} | sed -e "s/\(xpack-${gcc_target}-gcc-[0-9.]*-[0-9.]*\)-\([a-z0-9]*\)-\([a-z0-9]*\).*/\3/")
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
if [[ "${archive_name}" == *.zip ]]
then
  unzip -q "${work_absolute_path}/cache/${archive_name}"
else 
  tar xf "${work_absolute_path}/cache/${archive_name}"
fi

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
