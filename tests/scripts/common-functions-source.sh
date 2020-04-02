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

  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-ar"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-as"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-ld"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-nm"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-objcopy"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-objdump"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-ranlib"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-size"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-strings"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-strip"

  run_app "${app_absolute_folder_path}/bin/${gcc_target}-ar" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-as" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-ld" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-nm" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-objcopy" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-objdump" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-ranlib" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-size" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-strings" --version
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-strip" --version
}

function run_gcc()
{
  echo
  echo "Testing if gcc starts properly..."

  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-gcc"
  show_libs "${app_absolute_folder_path}/bin/${gcc_target}-g++"

  run_app "${app_absolute_folder_path}/bin/${gcc_target}-gcc" --help
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-gcc" -dumpversion
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-gcc" -dumpmachine
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-gcc" -print-multi-lib
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-gcc" -dumpspecs | wc -l
 
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

  run_app "${app_absolute_folder_path}/bin/${gcc_target}-gcc" -o hello-c.elf -specs=nosys.specs hello.c

  run_app "${app_absolute_folder_path}/bin/${gcc_target}-gcc" -o hello.c.o -c -flto hello.c
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-gcc" -o hello-c-lto.elf -specs=nosys.specs -flto -v hello.c.o

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

  run_app "${app_absolute_folder_path}/bin/${gcc_target}-g++" -o hello-cpp.elf -specs=nosys.specs hello.cpp

  run_app "${app_absolute_folder_path}/bin/${gcc_target}-g++" -o hello.cpp.o -c -flto hello.cpp
  run_app "${app_absolute_folder_path}/bin/${gcc_target}-g++" -o hello-cpp-lto.elf -specs=nosys.specs -flto -v hello.cpp.o

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

  if [ ! -x "${app_absolute_folder_path}/bin/${gcc_target}-gdb${suffix}${exe}" ]
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
    show_libs "${app_absolute_folder_path}/bin/${gcc_target}-gdb${suffix}"

    echo
    run_app "${app_absolute_folder_path}/bin/${gcc_target}-gdb${suffix}" --version
    run_app "${app_absolute_folder_path}/bin/${gcc_target}-gdb${suffix}" --config

    # This command is known to fail with 'Abort trap: 6' (SIGABRT)
    run_app "${app_absolute_folder_path}/bin/${gcc_target}-gdb${suffix}" \
      --nh \
      --nx \
      -ex='show language' \
      -ex='set language auto' \
      -ex='quit'
    
    if [ ! -z "${suffix}" ]
    then
      local out=$("${app_absolute_folder_path}/bin/${gcc_target}-gdb${suffix}" \
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
