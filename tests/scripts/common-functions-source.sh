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
  local gcc_target_prefix="arm-none-eabi"

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
