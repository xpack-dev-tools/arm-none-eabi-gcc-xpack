# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Common functions used in various tests.
#
# Requires 
# - app_absolute_folder_path
# - test_absolute_folder_path
# - archive_platform (win32|linux|darwin)

# -----------------------------------------------------------------------------

function detect_architecture()
{
  uname -a

  uname_platform=$(uname -s | tr '[:upper:]' '[:lower:]')
  uname_machine=$(uname -m | tr '[:upper:]' '[:lower:]')

  node_platform="${uname_platform}"
  # Travis uses Msys2; git for Windows uses mingw-w64.
  if [[ "${uname_platform}" == msys_nt* ]] \
  || [[ "${uname_platform}" == mingw64_nt* ]] \
  || [[ "${uname_platform}" == mingw32_nt* ]]
  then
    node_platform="win32"
  fi

  node_architecture=""
  bits=""
  if [ "${uname_machine}" == "x86_64" ]
  then
    node_architecture="x64"
    bits="64"
  elif [ "${uname_machine}" == "i386" -o "${uname_machine}" == "i586" -o "${uname_machine}" == "i686" ]
  then
    node_architecture="x32"
    bits="32"
  elif [ "${uname_machine}" == "aarch64" ]
  then
    node_architecture="arm64"
    bits="64"
  elif [ "${uname_machine}" == "armv7l" -o "${uname_machine}" == "armv8l" ]
  then
    node_architecture="arm"
    bits="32"
  else
    echo "${uname_machine} not supported"
    exit 1
  fi
}

function prepare_env() 
{
  container_work_folder_absolute_path="/Host/Work"
  container_repo_folder_absolute_path="/Host/repo"

  if [ -f "/.dockerenv" ]
  then
    work_folder_absolute_path="${container_work_folder_absolute_path}"
    repo_folder_absolute_path="${container_repo_folder_absolute_path}"
  else
    work_folder_absolute_path="${HOME}/Work"
    repo_folder_absolute_path="${TRAVIS_BUILD_DIR}"
  fi

  cache_absolute_folder_path="${work_folder_absolute_path}/cache"

  gcc_target_prefix="arm-none-eabi"
  # Extract only the first line
  version="$(cat ${repo_folder_absolute_path}/scripts/VERSION | sed -e '2,$d')"

  # Always in the user home, even when inside a container.
  test_absolute_folder_path="${HOME}/test-arm-none-eabi-gcc"
}

# -----------------------------------------------------------------------------

# Requires base_url and lots of other variables.
function install_archive()
{
  local archive_extension
  local archive_architecture="${node_architecture}"
  if [ "${node_platform}" == "win32" ]
  then
    archive_extension="zip"
    if [ "${force_32_bit}" == "y" ]
    then
      archive_architecture="x32"
    fi
  else
    archive_extension="tar.gz"
  fi
  archive_name="xpack-${gcc_target_prefix}-gcc-${version}-${node_platform}-${archive_architecture}.${archive_extension}"
  archive_folder_name="xpack-${gcc_target_prefix}-gcc-${version}"

  mkdir -p "${cache_absolute_folder_path}"

  if [ ! -f "${cache_absolute_folder_path}/${archive_name}" ]
  then
    echo
    echo "Downloading ${archive_name}..."
    curl -L --fail -o "${cache_absolute_folder_path}/${archive_name}" \
      "${base_url}/${archive_name}"
  fi

  app_absolute_folder_path="${test_absolute_folder_path}/${archive_folder_name}"

  rm -rf "${app_absolute_folder_path}"

  mkdir -p "${test_absolute_folder_path}"
  cd "${test_absolute_folder_path}"

  echo
  echo "Extracting ${archive_name}..."
  if [[ "${archive_name}" == *.zip ]]
  then
    unzip -q "${cache_absolute_folder_path}/${archive_name}"
  else 
    tar xf "${cache_absolute_folder_path}/${archive_name}"
  fi

  ls -lL "${app_absolute_folder_path}"
}

# -----------------------------------------------------------------------------

# $1 = image name
# $2 = base URL
function docker_run_test() {
  local image_name="$1"
  shift

  local base_url="$1"
  shift

  (
    prefix32="${prefix32:-""}"

    docker run \
      --tty \
      --hostname "docker" \
      --workdir="/root" \
      --env DEBUG=${DEBUG} \
      --volume "${work_folder_absolute_path}:${container_work_folder_absolute_path}" \
      --volume "${repo_folder_absolute_path}:${container_repo_folder_absolute_path}" \
      "${image_name}" \
      ${prefix32} /bin/bash "${container_repo_folder_absolute_path}/tests/scripts/container-test.sh" \
        "${image_name}" \
        "${base_url}" \
        $@
  )
}

function docker_run_test_32() {
  (
    prefix32="linux32"

    docker_run_test $@
  )
}

# -----------------------------------------------------------------------------

function show_libs()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift
  if [ "${node_platform}" == "win32" ]
  then
    app_path+='.exe'
  fi

  if [ "${node_platform}" == "linux" ]
  then
    echo
    echo "readelf -d ${app_path} | grep 'ibrary'"
    readelf -d "${app_path}" | grep 'ibrary'
    echo
    echo "ldd ${app_path}"
    ldd "${app_path}" 2>&1
  elif [ "${node_platform}" == "darwin" ]
  then
    echo
    echo "otool -L ${app_path}"
    otool -L "${app_path}"
  fi
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

  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-ar"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-as"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-ld"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-nm"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-objcopy"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-objdump"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-ranlib"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-size"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-strings"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-strip"

  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-ar" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-as" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-ld" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-nm" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-objcopy" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-objdump" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-ranlib" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-size" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-strings" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-strip" --version
}

function run_gcc()
{
  echo
  echo "Testing if gcc starts properly..."

  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gcc"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-g++"

  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gcc" --help
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gcc" -dumpversion
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gcc" -dumpmachine
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gcc" -print-multi-lib
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gcc" -dumpspecs | wc -l
 
  echo
  echo "Testing if gcc compiles simple programs..."

  local tmp="${test_absolute_folder_path}-gcc"
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

  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gcc" -o hello-c.elf -specs=nosys.specs hello.c

  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gcc" -o hello.c.o -c -flto hello.c
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gcc" -o hello-c-lto.elf -specs=nosys.specs -flto -v hello.c.o

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

  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-g++" -o hello-cpp.elf -specs=nosys.specs hello.cpp

  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-g++" -o hello.cpp.o -c -flto hello.cpp
  run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-g++" -o hello-cpp-lto.elf -specs=nosys.specs -flto -v hello.cpp.o

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
  if [ "${node_platform}" == "win32" ]
  then
    exe=".exe"
  fi

  if [ ! -x "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}${exe}" ]
  then
    echo
    echo ">>> ${gcc_target_prefix}-gdb${suffix} not present, skipping..."
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
        if [ "${node_platform}" == "win32" ]
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
        if [ "${node_platform}" == "win32" ]
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

    # rm -rf "${app_absolute_folder_path}/bin/python27.dll"
    show_libs "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}"

    echo
    run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}" --version
    run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}" --config

    # This command is known to fail with 'Abort trap: 6' (SIGABRT)
    run_app "${app_absolute_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}" \
      --nh \
      --nx \
      -ex='show language' \
      -ex='set language auto' \
      -ex='quit'
    
    if [ ! -z "${suffix}" ]
    then
      local out=$("${app_absolute_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}" \
        --nh \
        --nx \
        -ex='python print("babu"+"riba")' \
        -ex='quit' | grep 'baburiba')
      if [ "${out}" == "baburiba" ]
      then
        echo
        echo "gdb${suffix} python print() functional."
      else
        echo
        echo "gdb${suffix} python print() not functional."
        exit 1
      fi
    fi
  )
}

# -----------------------------------------------------------------------------

function run_tests()
{
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
  echo "All tests completed successfully."

  echo
  run_app uname -a
  if [ "${node_platform}" == "linux" ]
  then
    run_app lsb_release -a
    run_app ldd --version
  elif [ "${node_platform}" == "darwin" ]
  then
    run_app sw_vers
  fi
}

# -----------------------------------------------------------------------------
