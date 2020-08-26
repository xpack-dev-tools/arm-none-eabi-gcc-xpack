# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the second edition of the GNU MCU Eclipse build 
# scripts. As the name implies, it should contain only functions and 
# should be included with 'source' by the container build scripts.

# -----------------------------------------------------------------------------

function host_custom_options()
{
  local help_message="$1"
  shift

  ACTION=""

  DO_BUILD_WIN=""
  IS_DEBUG=""
  IS_DEVELOP=""
  WITH_STRIP="y"
  IS_NATIVE="y"

  WITHOUT_MULTILIB=""
  WITH_PDF="y"
  WITH_HTML="n"
  WITH_NEWLIB_LTO="n"
  WITH_LIBS_LTO="n"

  WITH_TESTS="y"

  JOBS="1"

  while [ $# -gt 0 ]
  do
    case "$1" in

      clean|cleanlibs|cleanall)
        ACTION="$1"
        ;;

      --win|--windows)
        DO_BUILD_WIN="y"
        ;;

      --debug)
        IS_DEBUG="y"
        ;;

      --develop)
        IS_DEVELOP="y"
        ;;

      --jobs)
        shift
        JOBS=$1
        ;;

      --help)
        echo
        echo "Build a local/native ${DISTRO_UC_NAME} ${APP_UC_NAME}."
        echo "Usage:"
        # Some of the options are processed by the container script.
        echo "${help_message}"
        echo
        exit 0
        ;;

      # --- specific

      --disable-multilib)
        WITHOUT_MULTILIB="y"
        ;;

      --without-pdf)
        WITH_PDF="n"
        ;;

      --with-pdf)
        WITH_PDF="y"
        ;;

      --without-html)
        WITH_HTML="n"
        ;;

      --with-html)
        WITH_HTML="y"
        ;;

      --disable-strip)
        WITH_STRIP="n"
        shift
        ;;

      --disable-tests)
        WITH_TESTS="n"
        shift
        ;;

      *)
        echo "Unknown action/option $1"
        exit 1
        ;;

    esac
    shift

  done

  if [ "${DO_BUILD_WIN}" == "y" ]
  then
    if [ "${HOST_NODE_PLATFORM}" == "linux" ]
    then
      TARGET_PLATFORM="win32"
    else
      echo "Windows cross builds are available only on GNU/Linux."
      exit 1
    fi
  fi
}

# -----------------------------------------------------------------------------

function add_linux_install_path()
{
  # Verify that the compiler is there.
  "${WORK_FOLDER_PATH}/${LINUX_INSTALL_PATH}/bin/${GCC_TARGET}-gcc" --version

  export PATH="${WORK_FOLDER_PATH}/${LINUX_INSTALL_PATH}/bin:${PATH}"
  echo ${PATH}

  # export LD_LIBRARY_PATH="${WORK_FOLDER_PATH}/${LINUX_INSTALL_PATH}/bin:${LD_LIBRARY_PATH}"
  # echo ${LD_LIBRARY_PATH}
}

# -----------------------------------------------------------------------------

function define_flags_for_target()
{
  local optimize="${CFLAGS_OPTIMIZATIONS_FOR_TARGET}"
  if [ "$1" == "" ]
  then
    # Normally this is the default, but for just in case.
    optimize+=" -fexceptions"
  elif [ "$1" == "-nano" ]
  then
    # For newlib-nano optimize for size and disable exceptions.
    optimize="$(echo ${optimize} | sed -e 's/-O[123]/-Os/') -fno-exceptions"
  fi

  # Note the intentional `-g`.
  CFLAGS_FOR_TARGET="${optimize} -g" 
  CXXFLAGS_FOR_TARGET="${optimize} -g"
  
  if [ "${WITH_LIBS_LTO}" == "y" ]
  then
    CFLAGS_FOR_TARGET+=" -flto -ffat-lto-objects"
    CXXFLAGS_FOR_TARGET+=" -flto -ffat-lto-objects"
  fi 
}
