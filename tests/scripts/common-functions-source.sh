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
# - app_folder_path
# - test_folder_path
# - archive_platform (win32|linux|darwin)

# -----------------------------------------------------------------------------

function test_binutils()
{
  echo
  echo "Testing if binutils start properly..."

  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-ar"
  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-as"
  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-ld"
  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-nm"
  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-objcopy"
  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-objdump"
  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-ranlib"
  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-size"
  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-strings"
  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-strip"

  run_app "${app_folder_path}/bin/${gcc_target_prefix}-ar" --version
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-as" --version
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-ld" --version
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-nm" --version
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-objcopy" --version
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-objdump" --version
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-ranlib" --version
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-size" --version
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-strings" --version
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-strip" --version
}

function test_gcc()
{
  echo
  echo "Testing if gcc starts properly..."

  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-gcc"
  show_libs "${app_folder_path}/bin/${gcc_target_prefix}-g++"

  run_app "${app_folder_path}/bin/${gcc_target_prefix}-gcc" --help
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-gcc" -dumpversion
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-gcc" -dumpmachine
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-gcc" -print-multi-lib
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-gcc" -dumpspecs | wc -l
 
  echo
  echo "Testing if gcc compiles simple programs..."

  local tmp="${test_folder_path}-gcc"
  rm -rf "${tmp}"

  mkdir -pv "${tmp}"
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

  run_app "${app_folder_path}/bin/${gcc_target_prefix}-gcc" -o hello-c.elf -specs=nosys.specs hello.c

  run_app "${app_folder_path}/bin/${gcc_target_prefix}-gcc" -o hello.c.o -c -flto hello.c
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-gcc" -o hello-c-lto.elf -specs=nosys.specs -flto -v hello.c.o

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

  run_app "${app_folder_path}/bin/${gcc_target_prefix}-g++" -o hello-cpp.elf -specs=nosys.specs hello.cpp

  run_app "${app_folder_path}/bin/${gcc_target_prefix}-g++" -o hello.cpp.o -c -flto hello.cpp
  run_app "${app_folder_path}/bin/${gcc_target_prefix}-g++" -o hello-cpp-lto.elf -specs=nosys.specs -flto -v hello.cpp.o

  cd ..
  rm -rf "${tmp}"
}

function test_gdb()
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

  if [ ! -x "${app_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}${exe}" ]
  then
    echo
    echo ">>> ${gcc_target_prefix}-gdb${suffix} not present, tests skipped."
    return
  fi

  (
    echo
    echo "Testing if gdb${suffix} starts properly..."

    show_libs "${app_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}"

    echo
    run_app "${app_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}" --version
    run_app "${app_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}" --config

    # This command is known to fail with 'Abort trap: 6' (SIGABRT)
    run_app "${app_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}" \
      --nh \
      --nx \
      -ex='show language' \
      -ex='set language auto' \
      -ex='quit'

    if [ "${suffix}" == "-py3" ]
    then
      # Show Python paths.
      run_app "${app_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}" \
        --nh \
        --nx \
        -ex='python import sys; print(sys.prefix)' \
        -ex='python import sys; import os; print(os.pathsep.join(sys.path))' \
        -ex='quit'
    fi

    if [ ! -z "${suffix}" ]
    then
      local out=$("${app_folder_path}/bin/${gcc_target_prefix}-gdb${suffix}" \
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
  local gcc_target_prefix="arm-none-eabi"

  test_binutils

  test_gcc

  test_gdb

  if [ "${has_gdb_py3}" == "y" ]
  then
    test_gdb "-py3"
  else
    echo
    echo ">>> gdb-py3 tests skipped."
  fi

  echo
  echo "Checking the Python shared libraries."

  for file_path in $(find "${app_folder_path}" -name 'libpython*so*')
  do
    run_app file "${file_path}"
    run_app ldd -v "${file_path}" || true
  done

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
