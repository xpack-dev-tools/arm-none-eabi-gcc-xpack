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

function download_gcc_combo() 
{
  # https://developer.arm.com/open-source/gnu-toolchain/gnu-rm
  # https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads

  cd "${SOURCES_FOLDER_PATH}"

  download_and_extract "${GCC_COMBO_URL}" "${GCC_COMBO_ARCHIVE}" \
    "${GCC_COMBO_FOLDER_NAME}"
}

# -----------------------------------------------------------------------------

function build_binutils()
{
  # https://ftp.gnu.org/gnu/binutils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=binutils-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

  local binutils_version="$1"
  # No versioning here, the inner archives use simple names.
  local binutils_folder_name="binutils-${binutils_version}"
  local binutils_patch="${binutils_folder_name}.patch"

  local binutils_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-${binutils_folder_name}-installed"

  if [ ! -f "${binutils_stamp_file_path}" ]
  then

    # Download binutils.
    if [ ! -d "${SOURCES_FOLDER_PATH}/${BINUTILS_SRC_FOLDER_NAME}" ]
    then
      (
        xbb_activate

        cd "${SOURCES_FOLDER_PATH}"
        if [ -n "${BINUTILS_GIT_URL}" ]
        then
          git_clone "${BINUTILS_GIT_URL}" "${BINUTILS_GIT_BRANCH}" \
            "${BINUTILS_GIT_COMMIT}" "${BINUTILS_SRC_FOLDER_NAME}"
          cd "${BINUTILS_SRC_FOLDER_NAME}"
          do_patch "${binutils_patch}"
        else
          # Note: define binutils_patch to the patch file name.
          extract "${GCC_COMBO_FOLDER_NAME}/src/binutils.tar.bz2" \
            "${BINUTILS_SRC_FOLDER_NAME}" "${binutils_patch}"
        fi
      )
    fi

    mkdir -pv "${LOGS_FOLDER_PATH}/${binutils_folder_name}"

    (
      mkdir -pv "${BUILD_FOLDER_PATH}/${binutils_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${binutils_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}" 
      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        LDFLAGS+=" -Wl,${XBB_FOLDER_PATH}/mingw/lib/CRT_glob.o"
      elif [ "${TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      env | sort

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running binutils configure..."
      
          bash "${SOURCES_FOLDER_PATH}/${BINUTILS_SRC_FOLDER_NAME}/configure" --help

          # ? --without-python --without-curses, --with-expat

          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${BINUTILS_SRC_FOLDER_NAME}/configure" \
            --prefix="${APP_PREFIX}" \
            --infodir="${APP_PREFIX_DOC}/info" \
            --mandir="${APP_PREFIX_DOC}/man" \
            --htmldir="${APP_PREFIX_DOC}/html" \
            --pdfdir="${APP_PREFIX_DOC}/pdf" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${GCC_TARGET} \
            \
            --with-pkgversion="${BRANDING}" \
            \
            --disable-nls \
            --disable-werror \
            --disable-sim \
            --disable-gdb \
            --enable-interwork \
            --enable-plugins \
            --with-sysroot="${APP_PREFIX}/${GCC_TARGET}" \
            \
            --enable-build-warnings=no \
            --with-system-zlib \
            
          cp "config.log" "${LOGS_FOLDER_PATH}/${binutils_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${binutils_folder_name}/configure-output.txt"
      fi

      (
        echo
        echo "Running binutils make..."
      
        # Build.
        run_verbose make -j ${JOBS} 

        if [ "${WITH_TESTS}" == "y" ]
        then
          run_verbose make check
        fi
      
        # Avoid strip here, it may interfere with patchelf.
        # make install-strip
        run_verbose make install

        (
          xbb_activate_tex

          if [ "${WITH_PDF}" == "y" ]
          then
            run_verbose make pdf
            run_verbose make install-pdf
          fi

          if [ "${WITH_HTML}" == "y" ]
          then
            run_verbose make html
            run_verbose make install-html
          fi
        )

        # Without this copy, the build for the nano version of the GCC second 
        # step fails with unexpected errors, like "cannot compute suffix of 
        # object files: cannot compile".
        copy_dir "${APP_PREFIX}" "${APP_PREFIX_NANO}"

        show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-ar"
        show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-as"
        show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-ld"
        show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-nm"
        show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-objcopy"
        show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-objdump"
        show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-ranlib"
        show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-size"
        show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-strings"
        show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-strip"

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${binutils_folder_name}/make-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${BINUTILS_SRC_FOLDER_NAME}" \
        "${binutils_folder_name}"

    )

    touch "${binutils_stamp_file_path}"

  else
    echo "Component binutils already installed."
  fi

  tests_add "test_binutils"
}

function test_binutils()
{
  (
    xbb_activate_installed_bin

    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-ar"
    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-as"
    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-ld"
    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-nm"
    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-objcopy"
    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-objdump"
    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-ranlib"
    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-size"
    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-strings"
    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-strip"

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

  )
}

function build_gcc_first()
{
  local gcc_first_folder_name="gcc-${GCC_VERSION}-first"
  local gcc_first_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-${gcc_first_folder_name}-installed"

  if [ ! -f "${gcc_first_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    extract "${GCC_COMBO_FOLDER_NAME}/src/gcc.tar.bz2" \
      "${GCC_SRC_FOLDER_NAME}" "${GCC_PATCH}"

    mkdir -pv "${LOGS_FOLDER_PATH}/${gcc_first_folder_name}"

    (
      mkdir -pv "${BUILD_FOLDER_PATH}/${gcc_first_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${gcc_first_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_APP}" 
      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi      
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      define_flags_for_target ""

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      export CFLAGS_FOR_TARGET 
      export CXXFLAGS_FOR_TARGET

      env | sort

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gcc first stage configure..."
      
          bash "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/configure" --help

          # https://gcc.gnu.org/install/configure.html
          # --enable-shared[=package[,…]] build shared versions of libraries
          # --enable-tls specify that the target supports TLS (Thread Local Storage). 
          # --enable-nls enables Native Language Support (NLS)
          # --enable-checking=list the compiler is built to perform internal consistency checks of the requested complexity. ‘yes’ (most common checks)
          # --with-headers=dir specify that target headers are available when building a cross compiler
          # --with-newlib Specifies that ‘newlib’ is being used as the target C library. This causes `__eprintf`` to be omitted from `libgcc.a`` on the assumption that it will be provided by newlib.
          # --enable-languages=c newlib does not use C++, so C should be enough

          # --enable-checking=no ???

          # --enable-lto make it explicit, Arm uses the default.

          # Prefer an explicit libexec folder.
          # --libexecdir="${APP_PREFIX}/lib" 

          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/configure" \
            --prefix="${APP_PREFIX}"  \
            --infodir="${APP_PREFIX_DOC}/info" \
            --mandir="${APP_PREFIX_DOC}/man" \
            --htmldir="${APP_PREFIX_DOC}/html" \
            --pdfdir="${APP_PREFIX_DOC}/pdf" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${GCC_TARGET} \
            \
            --with-pkgversion="${BRANDING}" \
            \
            --enable-languages=c \
            --enable-lto \
            --disable-decimal-float \
            --disable-libffi \
            --disable-libgomp \
            --disable-libmudflap \
            --disable-libquadmath \
            --disable-libssp \
            --disable-libstdcxx-pch \
            --disable-nls \
            --disable-threads \
            --disable-tls \
            --with-newlib \
            --without-headers \
            --with-gnu-as \
            --with-gnu-ld \
            --with-python-dir=share/gcc-${GCC_TARGET} \
            --with-sysroot="${APP_PREFIX}/${GCC_TARGET}" \
            ${MULTILIB_FLAGS} \
            \
            --disable-build-format-warnings \
            --with-system-zlib \
          
          cp "config.log" "${LOGS_FOLDER_PATH}/${gcc_first_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${gcc_first_folder_name}/configure-output.txt"
      fi

      (
        # Partial build, without documentation.
        echo
        echo "Running gcc first stage make..."

        # No need to make 'all', 'all-gcc' is enough to compile the libraries.
        # Parallel builds may fail.
        run_verbose make -j ${JOBS} all-gcc
        # make all-gcc

        # No -strip available here.
        run_verbose make install-gcc

        # Strip?

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${gcc_first_folder_name}/make-output.txt"
    )

    touch "${gcc_first_stamp_file_path}"

  else
    echo "Component gcc first stage already installed."
  fi
}

# For the nano build, call it with "-nano".
# $1="" or $1="-nano"
function build_newlib()
{
  local newlib_folder_name="newlib-${NEWLIB_VERSION}$1"
  local newlib_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-${newlib_folder_name}-installed"

  if [ ! -f "${newlib_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    extract "${GCC_COMBO_FOLDER_NAME}/src/newlib.tar.bz2" "${NEWLIB_SRC_FOLDER_NAME}"

    mkdir -pv "${LOGS_FOLDER_PATH}/${newlib_folder_name}"

    (
      mkdir -pv "${BUILD_FOLDER_PATH}/${newlib_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${newlib_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      # Add the gcc first stage binaries to the path.
      PATH="${APP_PREFIX}/bin:${PATH}"

      CPPFLAGS="${XBB_CPPFLAGS}" 
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      define_flags_for_target "$1"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS

      export CFLAGS_FOR_TARGET
      export CXXFLAGS_FOR_TARGET

      env | sort

      if [ ! -f "config.status" ]
      then
        (
          # --disable-nls do not use Native Language Support
          # --enable-newlib-io-long-double   enable long double type support in IO functions printf/scanf
          # --enable-newlib-io-long-long   enable long long type support in IO functions like printf/scanf
          # --enable-newlib-io-c99-formats   enable C99 support in IO functions like printf/scanf
          # --enable-newlib-register-fini   enable finalization function registration using atexit
          # --disable-newlib-supplied-syscalls disable newlib from supplying syscalls (__NO_SYSCALLS__)

          # --disable-newlib-fvwrite-in-streamio    disable iov in streamio
          # --disable-newlib-fseek-optimization    disable fseek optimization
          # --disable-newlib-wide-orient    Turn off wide orientation in streamio
          # --disable-newlib-unbuf-stream-opt    disable unbuffered stream optimization in streamio
          # --enable-newlib-nano-malloc    use small-footprint nano-malloc implementation
          # --enable-lite-exit	enable light weight exit
          # --enable-newlib-global-atexit	enable atexit data structure as global
          # --enable-newlib-nano-formatted-io    Use nano version formatted IO
          # --enable-newlib-reent-small

          # --enable-newlib-retargetable-locking ???

          echo
          echo "Running newlib$1 configure..."
      
          bash "${SOURCES_FOLDER_PATH}/${NEWLIB_SRC_FOLDER_NAME}/configure" --help

          # I still did not figure out how to define a variable with
          # the list of options, such that it can be extended, so the
          # brute force approach is to duplicate the entire call.

          if [ "$1" == "" ]
          then

            # Extra options compared to Arm 9.3.1 distribution:
            # --enable-newlib-io-long-double 
            run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${NEWLIB_SRC_FOLDER_NAME}/configure" \
              --prefix="${APP_PREFIX}"  \
              --infodir="${APP_PREFIX_DOC}/info" \
              --mandir="${APP_PREFIX_DOC}/man" \
              --htmldir="${APP_PREFIX_DOC}/html" \
              --pdfdir="${APP_PREFIX_DOC}/pdf" \
              \
              --build=${BUILD} \
              --host=${HOST} \
              --target="${GCC_TARGET}" \
              \
              --enable-newlib-io-long-double \
              --enable-newlib-register-fini \
              --enable-newlib-retargetable-locking \
              --enable-newlib-reent-check-verify \
              --disable-newlib-supplied-syscalls \
              --disable-nls \
              \
              --enable-newlib-io-long-long \
              --enable-newlib-io-c99-formats \

          elif [ "$1" == "-nano" ]
          then

            # --enable-newlib-io-long-long and --enable-newlib-io-c99-formats
            # are currently ignored if --enable-newlib-nano-formatted-io.
            # --enable-newlib-register-fini is debatable, was removed.
            run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${NEWLIB_SRC_FOLDER_NAME}/configure" \
              --prefix="${APP_PREFIX_NANO}"  \
              \
              --build=${BUILD} \
              --host=${HOST} \
              --target="${GCC_TARGET}" \
              \
              --disable-newlib-supplied-syscalls \
              --enable-newlib-reent-check-verify \
              --enable-newlib-reent-small \
              --enable-newlib-retargetable-locking \
              --disable-newlib-fvwrite-in-streamio \
              --disable-newlib-fseek-optimization \
              --disable-newlib-wide-orient \
              --enable-newlib-nano-malloc \
              --disable-newlib-unbuf-stream-opt \
              --enable-lite-exit \
              --enable-newlib-global-atexit \
              --enable-newlib-nano-formatted-io \
              --disable-nls \
            
          else
            echo "Unsupported build_newlib arg $1"
            exit 1
          fi

          cp "config.log" "${LOGS_FOLDER_PATH}/${newlib_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${newlib_folder_name}/configure-output.txt"
      fi

      (
        # Partial build, without documentation.
        echo
        echo "Running newlib$1 make..."

        # Parallel builds may fail.
        run_verbose make -j ${JOBS}
        # make

        # Top make fails with install-strip due to libgloss make.
        run_verbose make install

        if [ "$1" == "" ]
        then

          if [ "${WITH_PDF}" == "y" ]
          then

            # Warning, parallel build failed on Debian 32-bit.

            (
              if [[ "${RELEASE_VERSION}" =~ 5\.4\.1-* ]]
              then
                hack_pdfetex
              fi

              xbb_activate_tex

              run_verbose make pdf
            )

            install -v -d "${APP_PREFIX_DOC}/pdf"

            install -v -c -m 644 \
              "${GCC_TARGET}/libgloss/doc/porting.pdf" "${APP_PREFIX_DOC}/pdf"
            install -v -c -m 644 \
              "${GCC_TARGET}/newlib/libc/libc.pdf" "${APP_PREFIX_DOC}/pdf"
            install -v -c -m 644 \
              "${GCC_TARGET}/newlib/libm/libm.pdf" "${APP_PREFIX_DOC}/pdf"

          fi

          if [ "${WITH_HTML}" == "y" ]
          then

            run_verbose make html

            install -v -d "${APP_PREFIX_DOC}/html"

            copy_dir "${GCC_TARGET}/newlib/libc/libc.html" "${APP_PREFIX_DOC}/html/libc"
            copy_dir "${GCC_TARGET}/newlib/libm/libm.html" "${APP_PREFIX_DOC}/html/libm"

          fi

        fi

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${newlib_folder_name}/make-output.txt"

      if [ "$1" == "" ]
      then
        copy_license \
          "${SOURCES_FOLDER_PATH}/${NEWLIB_SRC_FOLDER_NAME}" \
          "${NEWLIB_SRC_FOLDER_NAME}-${NEWLIB_VERSION}"
      fi

    )

    touch "${newlib_stamp_file_path}"
  else
    echo "Component newlib$1 already installed."
  fi
}

# -----------------------------------------------------------------------------

function copy_nano_libs() 
{
  local src_folder="$1"
  local dst_folder="$2"

  if [ -f "${src_folder}/libstdc++.a" ]
  then
    cp -v -f "${src_folder}/libstdc++.a" "${dst_folder}/libstdc++_nano.a"
  fi
  if [ -f "${src_folder}/libsupc++.a" ]
  then
    cp -v -f "${src_folder}/libsupc++.a" "${dst_folder}/libsupc++_nano.a"
  fi
  cp -v -f "${src_folder}/libc.a" "${dst_folder}/libc_nano.a"
  cp -v -f "${src_folder}/libg.a" "${dst_folder}/libg_nano.a"
  if [ -f "${src_folder}/librdimon.a" ]
  then
    cp -v -f "${src_folder}/librdimon.a" "${dst_folder}/librdimon_nano.a"
  fi

  cp -v -f "${src_folder}/nano.specs" "${dst_folder}/"
  if [ -f "${src_folder}/rdimon.specs" ]
  then
    cp -v -f "${src_folder}/rdimon.specs" "${dst_folder}/"
  fi
  cp -v -f "${src_folder}/nosys.specs" "${dst_folder}/"
  cp -v -f "${src_folder}"/*crt0.o "${dst_folder}/"
}

# Copy target libraries from each multilib folders.
# $1=source
# $2=destination
# $3=target gcc
function copy_multi_libs()
{
  local -a multilibs
  local multilib
  local multi_folder
  local src_folder="$1"
  local dst_folder="$2"
  local gcc_target="$3"

  echo ${gcc_target}
  multilibs=( $("${gcc_target}" -print-multi-lib 2>/dev/null) )
  if [ ${#multilibs[@]} -gt 0 ]
  then
    for multilib in "${multilibs[@]}"
    do
      multi_folder="${multilib%%;*}"
      copy_nano_libs "${src_folder}/${multi_folder}" \
        "${dst_folder}/${multi_folder}"
    done
  else
    copy_nano_libs "${src_folder}" "${dst_folder}"
  fi
}

# -----------------------------------------------------------------------------

function copy_linux_libs()
{
  local copy_linux_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-copy-linux-completed"
  if [ ! -f "${copy_linux_stamp_file_path}" ]
  then

    local linux_path="${LINUX_INSTALL_PATH}"

    (
      cd "${WORK_FOLDER_PATH}"

      copy_dir "${linux_path}/${GCC_TARGET}/lib" "${APP_PREFIX}/${GCC_TARGET}/lib"
      copy_dir "${linux_path}/${GCC_TARGET}/include" "${APP_PREFIX}/${GCC_TARGET}/include"
      copy_dir "${linux_path}/include" "${APP_PREFIX}/include"
      copy_dir "${linux_path}/lib" "${APP_PREFIX}/lib"
      copy_dir "${linux_path}/share" "${APP_PREFIX}/share"
    )

    (
      cd "${APP_PREFIX}"
      find "${GCC_TARGET}/lib" "${GCC_TARGET}/include" "include" "lib" "share" \
        -perm /111 -and ! -type d \
        -exec rm '{}' ';'
    )
    touch "${copy_linux_stamp_file_path}"

  else
    echo "Component copy-linux-libs already processed."
  fi
}

# -----------------------------------------------------------------------------

# For the nano build, call it with "-nano".
# $1="" or $1="-nano"
function build_gcc_final()
{
  local gcc_final_folder_name="gcc-${GCC_VERSION}-final$1"
  local gcc_final_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-${gcc_final_folder_name}-installed"

  if [ ! -f "${gcc_final_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    extract "${GCC_COMBO_FOLDER_NAME}/src/gcc.tar.bz2" \
      "${GCC_SRC_FOLDER_NAME}" "${GCC_PATCH}"

    mkdir -pv "${LOGS_FOLDER_PATH}/${gcc_final_folder_name}"

    (
      mkdir -pv "${BUILD_FOLDER_PATH}/${gcc_final_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${gcc_final_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}" 
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}" 
      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi      
      # Do not add CRT_glob.o here, it will fail with already defined,
      # since it is already handled by --enable-mingw-wildcard.
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      define_flags_for_target "$1"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS 
      export LDFLAGS        

      export CFLAGS_FOR_TARGET
      export CXXFLAGS_FOR_TARGET

      local mingw_wildcard="--disable-mingw-wildcard"

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        add_linux_install_path

        mingw_wildcard="--enable-mingw-wildcard"

        export AR_FOR_TARGET=${GCC_TARGET}-ar
        export NM_FOR_TARGET=${GCC_TARGET}-nm
        export OBJDUMP_FOR_TARET=${GCC_TARGET}-objdump
        export STRIP_FOR_TARGET=${GCC_TARGET}-strip
        export CC_FOR_TARGET=${GCC_TARGET}-gcc
        export GCC_FOR_TARGET=${GCC_TARGET}-gcc
        export CXX_FOR_TARGET=${GCC_TARGET}-g++
      fi

      env | sort

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gcc$1 final stage configure..."
      
          bash "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/configure" --help

          # https://gcc.gnu.org/install/configure.html
          # --enable-shared[=package[,…]] build shared versions of libraries
          # --enable-tls specify that the target supports TLS (Thread Local Storage). 
          # --enable-nls enables Native Language Support (NLS)
          # --enable-checking=list the compiler is built to perform internal consistency checks of the requested complexity. ‘yes’ (most common checks)
          # --with-headers=dir specify that target headers are available when building a cross compiler
          # --with-newlib Specifies that ‘newlib’ is being used as the target C library. This causes `__eprintf`` to be omitted from `libgcc.a`` on the assumption that it will be provided by newlib.
          # --enable-languages=c,c++ Support only C/C++, ignore all other.

          # Prefer an explicit libexec folder.
          # --libexecdir="${APP_PREFIX}/lib" \

          # --enable-lto make it explicit, Arm uses the default.
          # --with-native-system-header-dir is needed to locate stdio.h, to
          # prevent -Dinhibit_libc, which will skip some functionality, 
          # like libgcov.
          if [ "$1" == "" ]
          then

            run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/configure" \
              --prefix="${APP_PREFIX}"  \
              --infodir="${APP_PREFIX_DOC}/info" \
              --mandir="${APP_PREFIX_DOC}/man" \
              --htmldir="${APP_PREFIX_DOC}/html" \
              --pdfdir="${APP_PREFIX_DOC}/pdf" \
              \
              --build=${BUILD} \
              --host=${HOST} \
              --target=${GCC_TARGET} \
              \
              --with-pkgversion="${BRANDING}" \
              \
              --enable-languages=c,c++ \
              ${mingw_wildcard} \
              --enable-plugins \
              --enable-lto \
              --disable-decimal-float \
              --disable-libffi \
              --disable-libgomp \
              --disable-libmudflap \
              --disable-libquadmath \
              --disable-libssp \
              --disable-libstdcxx-pch \
              --disable-nls \
              --disable-threads \
              --disable-tls \
              --with-gnu-as \
              --with-gnu-ld \
              --with-newlib \
              --with-headers=yes \
              --with-python-dir="share/gcc-${GCC_TARGET}" \
              --with-sysroot="${APP_PREFIX}/${GCC_TARGET}" \
              --with-native-system-header-dir="/include" \
              ${MULTILIB_FLAGS} \
              \
              --disable-build-format-warnings \
              --with-system-zlib

          elif [ "$1" == "-nano" ]
          then

            run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/configure" \
              --prefix="${APP_PREFIX_NANO}"  \
              \
              --build=${BUILD} \
              --host=${HOST} \
              --target=${GCC_TARGET} \
              \
              --with-pkgversion="${BRANDING}" \
              \
              --enable-languages=c,c++ \
              --disable-decimal-float \
              --disable-libffi \
              --disable-libgomp \
              --disable-libmudflap \
              --disable-libquadmath \
              --disable-libssp \
              --disable-libstdcxx-pch \
              --disable-libstdcxx-verbose \
              --disable-nls \
              --disable-threads \
              --disable-tls \
              --with-gnu-as \
              --with-gnu-ld \
              --with-newlib \
              --with-headers=yes \
              --with-python-dir="share/gcc-${GCC_TARGET}" \
              --with-sysroot="${APP_PREFIX_NANO}/${GCC_TARGET}" \
              --with-native-system-header-dir="/include" \
              ${MULTILIB_FLAGS} \
              \
              --disable-build-format-warnings \
              --with-system-zlib

          fi
          cp "config.log" "${LOGS_FOLDER_PATH}/${gcc_final_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${gcc_final_folder_name}/configure-output.txt"
      fi

      (
        # Partial build, without documentation.
        echo
        echo "Running gcc$1 final stage make..."

        if [ "${TARGET_PLATFORM}" != "win32" ]
        then

          # Passing USE_TM_CLONE_REGISTRY=0 via INHIBIT_LIBC_CFLAGS to disable
          # transactional memory related code in crtbegin.o.
          # This is a workaround. Better approach is have a t-* to set this flag via
          # CRTSTUFF_T_CFLAGS

          # Parallel builds may fail.
          run_verbose make -j ${JOBS} INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0"
          # make INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0"

          # Avoid strip here, it may interfere with patchelf.
          # make install-strip
          run_verbose make install

          if [ "$1" == "-nano" ]
          then

            local target_gcc=""
            if [ "${TARGET_PLATFORM}" == "win32" ]
            then
              target_gcc="${GCC_TARGET}-gcc"
            else
              target_gcc="${APP_PREFIX_NANO}/bin/${GCC_TARGET}-gcc"
            fi

            # Copy the libraries after appending the `_nano` suffix.
            # Iterate through all multilib names.
            copy_multi_libs \
              "${APP_PREFIX_NANO}/${GCC_TARGET}/lib" \
              "${APP_PREFIX}/${GCC_TARGET}/lib" \
              "${target_gcc}"

            # Copy the nano configured newlib.h file into the location that nano.specs
            # expects it to be.
            mkdir -pv "${APP_PREFIX}/${GCC_TARGET}/include/newlib-nano"
            cp -v -f "${APP_PREFIX_NANO}/${GCC_TARGET}/include/newlib.h" \
              "${APP_PREFIX}/${GCC_TARGET}/include/newlib-nano/newlib.h"

          fi
          
        else

          # For Windows build only the GCC binaries, the libraries were copied 
          # from the Linux build.
          # Parallel builds may fail.
          run_verbose make -j ${JOBS} all-gcc
          # make all-gcc

          # No -strip here.
          run_verbose make install-gcc

          # Strip?

        fi

        if [ "$1" == "" ]
        then
          (
            xbb_activate_tex

            # Full build, with documentation.
            if [ "${WITH_PDF}" == "y" ]
            then
              run_verbose make pdf
              run_verbose make install-pdf
            fi

            if [ "${WITH_HTML}" == "y" ]
            then
              run_verbose make html
              run_verbose make install-html
            fi
          )
        fi

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gcc$1-final-output.txt"

      if [ "$1" == "" ]
      then
        copy_license \
          "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}" \
          "${GCC_SRC_FOLDER_NAME}-${GCC_VERSION}"
      fi

    )

    touch "${gcc_final_stamp_file_path}"

  else
    echo "Component gcc$1 final stage already installed."
  fi

  if [ "$1" == "" ]
  then
    tests_add "test_gcc"
  fi
}

function test_gcc()
{
  (
    xbb_activate_installed_bin

    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-gcc"
    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-g++"
    show_libs "${APP_PREFIX}/libexec/gcc/${GCC_TARGET}/${GCC_VERSION}/cc1"
    show_libs "${APP_PREFIX}/libexec/gcc/${GCC_TARGET}/${GCC_VERSION}/cc1plus"
    show_libs "${APP_PREFIX}/libexec/gcc/${GCC_TARGET}/${GCC_VERSION}/collect2"
    show_libs "${APP_PREFIX}/libexec/gcc/${GCC_TARGET}/${GCC_VERSION}/lto-wrapper"
    show_libs "${APP_PREFIX}/libexec/gcc/${GCC_TARGET}/${GCC_VERSION}/lto1"

    run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" --help
    run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" -dumpversion
    run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" -dumpmachine
    run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" -print-multi-lib
    run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gcc" -dumpspecs | wc -l
    
    local tmp=$(mktemp /tmp/gcc-test.XXXXX)
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
  )
}

# Called multile times, with and without python support.
# $1="" or $1="-py" or $1="-py3"
function build_gdb()
{
  # GDB Text User Interface
  # https://ftp.gnu.org/old-gnu/Manuals/gdb/html_chapter/gdb_19.html#SEC197

  local gdb_folder_name="gdb-${GDB_VERSION}$1"
  local gdb_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-${gdb_folder_name}-installed"

  if [ ! -f "${gdb_stamp_file_path}" ]
  then

    # Download gdb
    if [ ! -d "${SOURCES_FOLDER_PATH}/${GDB_SRC_FOLDER_NAME}" ]
    then
      cd "${SOURCES_FOLDER_PATH}"
      if [ -n "${GDB_GIT_URL}" ]
      then
        git_clone "${GDB_GIT_URL}" "${GDB_GIT_BRANCH}" \
          "${GDB_GIT_COMMIT}" "${GDB_SRC_FOLDER_NAME}"
        cd "${GDB_SRC_FOLDER_NAME}"
        do_patch "${GDB_PATCH}"
      else
        extract "${GCC_COMBO_FOLDER_NAME}/src/gdb.tar.bz2" \
          "${GDB_SRC_FOLDER_NAME}" "${GDB_PATCH}"
      fi
    fi

    mkdir -pv "${LOGS_FOLDER_PATH}/${gdb_folder_name}"

    (
      mkdir -pv "${BUILD_FOLDER_PATH}/${gdb_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${gdb_folder_name}"

      local platform_python2
      if [ -x "/Library/Frameworks/Python.framework/Versions/2.7/bin/python" ]
      then
        platform_python2="/Library/Frameworks/Python.framework/Versions/2.7/bin/python2"
      elif [ -x "/usr/bin/python2.7" ]
      then
        platform_python2="/usr/bin/python2.7"
      elif [ -x "/usr/bin/python2.6" ]
      then
        platform_python2="/usr/bin/python2.6"
      else
        set +e
        platform_python2="$(which python)"
        set -e
      fi

      local platform_python3
      if [ -x "/Library/Frameworks/Python.framework/Versions/3.7/bin/python3" ]
      then
        platform_python3="/Library/Frameworks/Python.framework/Versions/3.7/bin/python3"
      elif [ -x "/usr/bin/python3.7" ]
      then
        platform_python3="/usr/bin/python3.7"
      elif [ -x "/usr/bin/python3.6" ]
      then
        platform_python3="/usr/bin/python3.6"
      else
        set +e
        platform_python3="$(which python3)"
        set -e
      fi

      xbb_activate
      # To pick up the python lib from XBB
      # xbb_activate_dev
      xbb_activate_installed_dev

      # No longer seen with XBB v3.2.
      if false # [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        # When compiled with GCC-7 it fails to run, due to
        # some problems with exceptions unwind.
        export CC=clang
        export CXX=clang++
      fi

      CPPFLAGS="${XBB_CPPFLAGS}" 
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
          
      # libiconv is used by Python3.
      # export LIBS="-liconv"
      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        # https://stackoverflow.com/questions/44150871/embeded-python3-6-with-mingw-in-c-fail-on-linking
        # ???
        CPPFLAGS+=" -DPy_BUILD_CORE_BUILTIN=1"

        if [ "$1" == "-py" ]
        then
          # Definition required by python-config.sh.
          export GNURM_PYTHON_WIN_DIR="${SOURCES_FOLDER_PATH}/${PYTHON2_SRC_FOLDER_NAME}"
        fi

        # From Arm script.
        LDFLAGS="${XBB_LDFLAGS_APP} -v -Wl,${XBB_FOLDER_PATH}/mingw/lib/CRT_glob.o"
        # Workaround for undefined reference to `__strcpy_chk' in GCC 9.
        # https://sourceforge.net/p/mingw-w64/bugs/818/
        LIBS="-lssp -liconv"
      elif [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        # This makes gdb-py fail!
        # Pick some system libraries from XBB, to avoid rebuilding them here.
        #        CPPFLAGS+=" -I${XBB_FOLDER_PATH}/include" 
        #        LDFLAGS+=" -L${XBB_FOLDER_PATH}/lib"
        LDFLAGS="${XBB_LDFLAGS_APP}"
        LIBS="-liconv -lncurses"
      elif [ "${TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS="${XBB_LDFLAGS_APP}"
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
        LIBS=""
      fi

      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        # Pick some system libraries from XBB, to avoid rebuilding them here.
        CPPFLAGS+=" -I${XBB_FOLDER_PATH}/include" 
        LDFLAGS+=" -L${XBB_FOLDER_PATH}/lib"
      fi

      CONFIG_PYTHON_PREFIX=""

      local extra_python_opts="--with-python=no"
      if [ "$1" == "-py" ]
      then
        if [ "${TARGET_PLATFORM}" == "win32" ]
        then
          extra_python_opts="--with-python=${SOURCES_FOLDER_PATH}/${GCC_COMBO_FOLDER_NAME}/python-config.sh"
        else
          if [ "${USE_PLATFORM_PYTHON}" == "y" ]
          then
            extra_python_opts="--with-python=${platform_python2}"
          else
            extra_python_opts="--with-python=$(which python2)"
          fi
          
          if [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            # Use the custom path, 2.7 will be removed from future macOS.
            CONFIG_PYTHON_PREFIX="/Library/Frameworks/Python.framework/Versions/2.7"
          elif [ "${TARGET_PLATFORM}" == "linux" ]
          then
            CONFIG_PYTHON_PREFIX="/usr/local"
          fi
        fi
      elif [ "$1" == "-py3" ]
      then
        if [ "${TARGET_PLATFORM}" == "win32" ]
        then
          extra_python_opts="--with-python=${BUILD_GIT_PATH}/patches/python3-config.sh"
        else
          if [ "${USE_PLATFORM_PYTHON3}" == "y" ]
          then
            extra_python_opts="--with-python=${platform_python3}"
          else
            extra_python_opts="--with-python=$(which python3)"
          fi

          if [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            CONFIG_PYTHON_PREFIX="/Library/Frameworks/Python.framework/Versions/3.7"
          elif [ "${TARGET_PLATFORM}" == "linux" ]
          then
            CONFIG_PYTHON_PREFIX="/usr/local"
          fi
        fi
      fi

      local tui_option
      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        tui_option="--disable-tui"
      else
        tui_option="--enable-tui"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
          
      export LDFLAGS
      export LIBS

      export CONFIG_PYTHON_PREFIX

      env | sort

      # python -c 'from distutils import sysconfig;print(sysconfig.PREFIX)'
      # python -c 'from distutils import sysconfig;print(sysconfig.EXEC_PREFIX)'

      # Default PYTHONHOME on macOS
      # /System/Library/Frameworks/Python.framework/Versions/2.7
      # /Library/Frameworks/Python.framework/Versions/3.7

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gdb$1 configure..."
   
          bash "${SOURCES_FOLDER_PATH}/${GDB_SRC_FOLDER_NAME}/gdb/configure" --help

          # Note that all components are disabled, except GDB.
          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${GDB_SRC_FOLDER_NAME}/configure" \
            --prefix="${APP_PREFIX}"  \
            --infodir="${APP_PREFIX_DOC}/info" \
            --mandir="${APP_PREFIX_DOC}/man" \
            --htmldir="${APP_PREFIX_DOC}/html" \
            --pdfdir="${APP_PREFIX_DOC}/pdf" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${GCC_TARGET} \
            \
            --with-pkgversion="${BRANDING}" \
            \
            --disable-nls \
            --disable-sim \
            --disable-gas \
            --disable-binutils \
            --disable-ld \
            --disable-gprof \
            --with-expat \
            --with-lzma=yes \
            --with-system-gdbinit="${APP_PREFIX}/${GCC_TARGET}/lib/gdbinit" \
            --with-gdb-datadir="${APP_PREFIX}/${GCC_TARGET}/share/gdb" \
            \
            ${extra_python_opts} \
            --program-prefix="${GCC_TARGET}-" \
            --program-suffix="$1" \
            \
            --disable-werror \
            --enable-build-warnings=no \
            --with-system-zlib \
            --without-guile \
            --without-babeltrace \
            --without-libunwind-ia64 \
            ${tui_option} \

          cp "config.log" "${LOGS_FOLDER_PATH}/${gdb_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${gdb_folder_name}/configure-output.txt"
      fi

      (
        echo
        echo "Running gdb$1 make..."

        # Build.
        run_verbose make -j ${JOBS}

        # install-strip fails, not only because of readline has no install-strip
        # but even after patching it tries to strip a non elf file
        # strip:.../install/riscv-none-gcc/bin/_inst.672_: file format not recognized
        run_verbose make install

        if [ "$1" == "" ]
        then
          (
            xbb_activate_tex

            if [ "${WITH_PDF}" == "y" ]
            then
              run_verbose make pdf
              run_verbose make install-pdf
            fi

            if [ "${WITH_HTML}" == "y" ]
            then
              run_verbose make html 
              run_verbose make install-html 
            fi
          )
        fi

        show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-gdb$1"

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${gdb_folder_name}/make-output.txt"

      if [ "$1" == "" ]
      then
        copy_license \
          "${SOURCES_FOLDER_PATH}/${GDB_SRC_FOLDER_NAME}" \
          "${gdb_folder_name}"
      fi

    )

    touch "${gdb_stamp_file_path}"
  else
    echo "Component gdb$1 already installed."
  fi

  tests_add "test_gdb$1"
}

function test_gdb_py()
{
  test_gdb "-py"
}

function test_gdb_py3()
{
  test_gdb "-py3"
}

function test_gdb()
{
  local suffix=""
  if [ $# -ge 1 ]
  then
    suffix="$1"
  fi

  if [ "${suffix}" != "" -a "${TARGET_PLATFORM}" == "win32" ]
  then
    (
      xbb_activate

      show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-gdb${suffix}"

      # Fails on Wine
      # ImportError: No module named site
      # 007b:fixme:msvcrt:__clean_type_info_names_internal (0x1e31e2e8) stub
      run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gdb${suffix}" --version || true
    )
    return 0
  fi

  # error while loading shared libraries: /Host/home/ilg/Work/arm-none-eabi-gcc-8.2.1-1.5/linux-x32/install/arm-none-eabi-gcc/bin/libpython3.7m.so.1.0: unsupported version 0 of Verneed record
  if [ "${suffix}" == "-py3" -a "${TARGET_PLATFORM}" == "linux" -a "${TARGET_ARCH}" == "x32" ]
  then
    return 0
  fi

  (
    # Required by gdb-py to access the python shared library.
    xbb_activate_installed_bin

    show_libs "${APP_PREFIX}/bin/${GCC_TARGET}-gdb${suffix}"

    # The original Python in Ubunutu XBB is too old and the test fails.
    # Use the XBB modern Python.
    if [ "${suffix}" == "-py" ]
    then
      echo
      python2 --version

      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        export PYTHONHOME="${XBB_FOLDER_PATH}"
      elif [ "${TARGET_PLATFORM}" == "win32" ]
      then
        # export PYTHONHOME="${XBB_FOLDER_PATH}"
        export PYTHONPATH="${XBB_FOLDER_PATH}/lib/python2.7"
      fi
    elif [ "${suffix}" == "-py3" ]
    then
      echo
      python3 --version

      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        export PYTHONHOME="${XBB_FOLDER_PATH}"
      fi
    fi

    set +u
    echo "PYTHONHOME=${PYTHONHOME}"
    echo "PYTHONPATH=${PYTHONPATH}"
    set -u

    run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gdb${suffix}" --version
    run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gdb${suffix}" --config

    # This command is known to fail with 'Abort trap: 6' (SIGABRT)
    run_app "${APP_PREFIX}/bin/${GCC_TARGET}-gdb${suffix}" \
      --nh \
      --nx \
      -ex='show language' \
      -ex='set language auto' \
      -ex='quit'
  )
}

function tidy_up() 
{
  (
    xbb_activate

    echo
    echo "Tidying up..."

    find "${APP_PREFIX}" -name "libiberty.a" -exec rm -v '{}' ';'
    find "${APP_PREFIX}" -name '*.la' -exec rm -v '{}' ';'

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      find "${APP_PREFIX}" -name "liblto_plugin.a" -exec rm -v '{}' ';'
      find "${APP_PREFIX}" -name "liblto_plugin.dll.a" -exec rm -v '{}' ';'
    fi
  )
}

function strip_libs()
{
  if [ "${WITH_STRIP}" == "y" ]
  then
    (
      xbb_activate

      PATH="${APP_PREFIX}/bin:${PATH}"

      echo
      echo "Stripping libraries..."

      cd "${WORK_FOLDER_PATH}"

      # which "${GCC_TARGET}-objcopy"

      local libs=$(find "${APP_PREFIX}" -name '*.[ao]')
      for lib in ${libs}
      do
        echo "${GCC_TARGET}-objcopy -R ... ${lib}"
        "${GCC_TARGET}-objcopy" -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${lib} || true
      done
    )
  fi
}

function copy_distro_files()
{
  (
    set +u

    xbb_activate

    rm -rf "${APP_PREFIX}/${DISTRO_INFO_NAME}"
    mkdir -pv "${APP_PREFIX}/${DISTRO_INFO_NAME}"

    copy_build_files

    echo
    echo "Copying Arm files..."

    cd "${SOURCES_FOLDER_PATH}/${GCC_COMBO_FOLDER_NAME}"

    install -v -c -m 644 "readme.txt" \
      "${APP_PREFIX}/${DISTRO_INFO_NAME}/arm-readme.txt"

    install -v -c -m 644 "release.txt" \
      "${APP_PREFIX}/${DISTRO_INFO_NAME}/arm-release.txt"

    echo
    echo "Copying distro files..."

    cd "${BUILD_GIT_PATH}"
    install -v -c -m 644 "scripts/${README_OUT_FILE_NAME}" \
      "${APP_PREFIX}/README.md"
  )
}

function final_tunings()
{
  # Create the missing LTO plugin links.
  # For `ar` to work with LTO objects, it needs the plugin in lib/bfd-plugins,
  # but the build leaves it where `ld` needs it. On POSIX, make a soft link.
  if [ "${FIX_LTO_PLUGIN}" == "y" ]
  then
    (
      cd "${APP_PREFIX}"

      echo
      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        echo
        echo "Copying ${LTO_PLUGIN_ORIGINAL_NAME}..."

        mkdir -pv "$(dirname ${LTO_PLUGIN_BFD_PATH})"

        if [ ! -f "${LTO_PLUGIN_BFD_PATH}" ]
        then
          local plugin_path="$(find * -type f -name ${LTO_PLUGIN_ORIGINAL_NAME})"
          if [ ! -z "${plugin_path}" ]
          then
            cp -v "${plugin_path}" "${LTO_PLUGIN_BFD_PATH}"
          else
            echo "${LTO_PLUGIN_ORIGINAL_NAME} not found."
            exit 1
          fi
        fi
      else
        echo
        echo "Creating ${LTO_PLUGIN_ORIGINAL_NAME} link..."

        mkdir -pv "$(dirname ${LTO_PLUGIN_BFD_PATH})"
        if [ ! -f "${LTO_PLUGIN_BFD_PATH}" ]
        then
          local plugin_path="$(find * -type f -name ${LTO_PLUGIN_ORIGINAL_NAME})"
          if [ ! -z "${plugin_path}" ]
          then
            ln -s -v "../../${plugin_path}" "${LTO_PLUGIN_BFD_PATH}"
          else
            echo "${LTO_PLUGIN_ORIGINAL_NAME} not found."
            exit 1
          fi
        fi
      fi
    )
  fi
}

# -----------------------------------------------------------------------------
