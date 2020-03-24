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


function do_zlib() 
{
  # http://zlib.net
  # http://zlib.net/fossils/

  # https://archlinuxarm.org/packages/aarch64/zlib/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zlib-static
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zlib-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-zlib

  # 2013-04-28 "1.2.8"
  # 2017-01-15 "1.2.11"

  ZLIB_FOLDER_NAME="zlib-${ZLIB_VERSION}"
  local zlib_archive="${ZLIB_FOLDER_NAME}.tar.gz"
  local zlib_url="http://zlib.net/fossils/${zlib_archive}"

  local zlib_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-zlib-${ZLIB_VERSION}-installed"
  if [ ! -f "${zlib_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${zlib_url}" "${zlib_archive}" "${ZLIB_FOLDER_NAME}"

    (
      if [ ! -d "${LIBS_BUILD_FOLDER_PATH}/${ZLIB_FOLDER_NAME}" ]
      then
        mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${ZLIB_FOLDER_NAME}"
        # Copy the sources in the build folder.
        cp -r "${SOURCES_FOLDER_PATH}/${ZLIB_FOLDER_NAME}"/* \
          "${LIBS_BUILD_FOLDER_PATH}/${ZLIB_FOLDER_NAME}"
      fi
      cd "${LIBS_BUILD_FOLDER_PATH}/${ZLIB_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      if [ "${TARGET_PLATFORM}" != "win32" ]
      then

        export CFLAGS="${XBB_CFLAGS} -Wno-shift-negative-value"
        # export LDFLAGS="${XBB_LDFLAGS_LIB}"

        # No config.status left, use the library.
        if [ ! -f "libz.a" ]
        then
          (
            echo
            echo "Running zlib configure..."

            bash "./configure" --help

            bash ${DEBUG} "./configure" \
              --prefix="${LIBS_INSTALL_FOLDER_PATH}" 
            
            cp "configure.log" "${LOGS_FOLDER_PATH}/configure-zlib-log.txt"
          ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-zlib-output.txt"
        fi

        (
          echo
          echo "Running zlib make..."

          # Build.
          make -j ${JOBS}

          if [ "${WITH_TESTS}" == "y" ]
          then
            make test
          fi

          make install
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-zlib-output.txt"
      else    
        (
          echo
          echo "Running zlib make..."

          # Build.
          make -f win32/Makefile.gcc \
            PREFIX=${CROSS_COMPILE_PREFIX}- \
            prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            CFLAGS="${XBB_CFLAGS} -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4"
          make -f win32/Makefile.gcc install \
            DESTDIR="${LIBS_INSTALL_FOLDER_PATH}/" \
            INCLUDE_PATH="include" \
            LIBRARY_PATH="lib" \
            BINARY_PATH="bin"

        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-zlib-output.txt"
      fi

      copy_license \
        "${SOURCES_FOLDER_PATH}/${ZLIB_FOLDER_NAME}" \
        "${ZLIB_FOLDER_NAME}"

    )

    touch "${zlib_stamp_file_path}"

  else
    echo "Library zlib already installed."
  fi
}

function do_gmp() 
{
  # https://gmplib.org
  # https://gmplib.org/download/gmp/

  # https://archlinuxarm.org/packages/aarch64/gmp/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gmp-hg

  # 01-Nov-2015 "6.1.0"
  # 16-Dec-2016 "6.1.2"
  # 17-Jan-2020 "6.2.0"

  GMP_FOLDER_NAME="gmp-${GMP_VERSION}"
  local gmp_archive="${GMP_FOLDER_NAME}.tar.xz"
  local gmp_url="https://gmplib.org/download/gmp/${gmp_archive}"

  local gmp_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-gmp-${GMP_VERSION}-installed"
  if [ ! -f "${gmp_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gmp_url}" "${gmp_archive}" "${GMP_FOLDER_NAME}"
    
    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${GMP_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${GMP_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="-Wno-unused-value -Wno-empty-translation-unit -Wno-tautological-compare -Wno-overflow"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      # ABI is mandatory, otherwise configure fails on 32-bit.
      # (see https://gmplib.org/manual/ABI-and-ISA.html)
      if [ "${TARGET_ARCH}" == "x64" -o "${TARGET_ARCH}" == "x32" ]
      then
        export ABI="${TARGET_BITS}"
      fi

      if [ ! -f "config.status" ]
      then 
        (
          echo
          echo "Running gmp configure..."

          # ABI is mandatory, otherwise configure fails on 32-bit.
          # (see https://gmplib.org/manual/ABI-and-ISA.html)

          bash "${SOURCES_FOLDER_PATH}/${GMP_FOLDER_NAME}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${GMP_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --enable-cxx \
            --enable-shared \
            --disable-static
            
          cp "config.log" "${LOGS_FOLDER_PATH}/config-gmp-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gmp-output.txt"
      fi

      (
        echo
        echo "Running gmp make..."

        # Build.
        # Parallel builds may fail.
        make -j ${JOBS}
        # make

        if [ "${WITH_TESTS}" == "y" ]
        then
          make check
        fi

        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gmp-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${GMP_FOLDER_NAME}" \
        "${GMP_FOLDER_NAME}"

    )

    touch "${gmp_stamp_file_path}"

  else
    echo "Library gmp already installed."
  fi
}

function do_mpfr()
{
  # http://www.mpfr.org
  # http://www.mpfr.org/history.html

  # https://archlinuxarm.org/packages/aarch64/mpfr/files/PKGBUILD
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/mpfr

  # 6 March 2016 "3.1.4"
  # 7 September 2017 "3.1.6"
  # 31 January 2019 "4.0.2" may fail mpc

  MPFR_FOLDER_NAME="mpfr-${MPFR_VERSION}"
  local mpfr_archive="${MPFR_FOLDER_NAME}.tar.xz"
  local mpfr_url="http://www.mpfr.org/${MPFR_FOLDER_NAME}/${mpfr_archive}"

  local mpfr_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-mpfr-${MPFR_VERSION}-installed"
  if [ ! -f "${mpfr_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${mpfr_url}" "${mpfr_archive}" "${MPFR_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${MPFR_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${MPFR_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then 
        (
          echo
          echo "Running mpfr configure..."

          bash "${SOURCES_FOLDER_PATH}/${MPFR_FOLDER_NAME}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${MPFR_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --disable-warnings 
            
          cp "config.log" "${LOGS_FOLDER_PATH}/config-mpfr-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-mpfr-output.txt"
      fi

      (
        echo
        echo "Running mpfr make..."

        # Build.
        # Parallel builds may fail.
        make -j ${JOBS}
        # make

        if [ "${WITH_TESTS}" == "y" ]
        then
          make check
        fi

        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-mpfr-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${MPFR_FOLDER_NAME}" \
        "${MPFR_FOLDER_NAME}"

    )
    touch "${mpfr_stamp_file_path}"

  else
    echo "Library mpfr already installed."
  fi
}

function do_mpc()
{
  # http://www.multiprecision.org/
  # ftp://ftp.gnu.org/gnu/mpc

  # https://archlinuxarm.org/packages/aarch64/mpc/files/PKGBUILD
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/libmpc

  # 20 Feb 2015 "1.0.3"
  # 2018-01-11 "1.1.0"

  MPC_FOLDER_NAME="mpc-${MPC_VERSION}"
  local mpc_archive="${MPC_FOLDER_NAME}.tar.gz"

  local mpc_url="ftp://ftp.gnu.org/gnu/mpc/${mpc_archive}"
  if [[ "${MPC_VERSION}" =~ 0\.* ]]
  then
    mpc_url="http://www.multiprecision.org/downloads/${mpc_archive}"
  fi

  local mpc_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-mpc-${MPC_VERSION}-installed"
  if [ ! -f "${mpc_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${mpc_url}" "${mpc_archive}" "${MPC_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${MPC_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${MPC_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-unused-value -Wno-empty-translation-unit -Wno-tautological-compare"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then 
        (
          echo
          echo "Running mpc configure..."
        
          bash "${SOURCES_FOLDER_PATH}/${MPC_FOLDER_NAME}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${MPC_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            
          cp "config.log" "${LOGS_FOLDER_PATH}/config-mpc-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-mpc-output.txt"
      fi

      (
        echo
        echo "Running mpc make..."

        # Build.
        make -j ${JOBS}

        if [ "${WITH_TESTS}" == "y" ]
        then
          make check
        fi

        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-mpc-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${MPC_FOLDER_NAME}" \
        "${MPC_FOLDER_NAME}"

    )
    touch "${mpc_stamp_file_path}"

  else
    echo "Library mpc already installed."
  fi
}

function do_isl()
{
  # http://isl.gforge.inria.fr

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=isl

  # 2015-06-12 "0.15"
  # 2016-01-15 "0.16.1"
  # 2016-12-20 "0.18"
  # 2019-03-26 "0.21"
  # 2020-01-16 "0.22"

  ISL_FOLDER_NAME="isl-${ISL_VERSION}"
  local isl_archive="${ISL_FOLDER_NAME}.tar.xz"
  if [[ "${ISL_VERSION}" =~ 0\.12\.* ]]
  then
    isl_archive="${ISL_FOLDER_NAME}.tar.gz"
  fi

  local isl_url="http://isl.gforge.inria.fr/${isl_archive}"

  local isl_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-isl-${ISL_VERSION}-installed"
  if [ ! -f "${isl_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${isl_url}" "${isl_archive}" "${ISL_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${ISL_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${ISL_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-dangling-else -Wno-header-guard"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then 
        (
          echo
          echo "Running isl configure..."

          bash "${SOURCES_FOLDER_PATH}/${ISL_FOLDER_NAME}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${ISL_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            
          cp "config.log" "${LOGS_FOLDER_PATH}/config-isl-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-isl-output.txt"
      fi

      (
        echo
        echo "Running isl make..."

        # Build.
        # Parallel builds may fail.
        make -j ${JOBS}
        # make

        if [ "${WITH_TESTS}" == "y" ]
        then
          make check
        fi

        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-isl-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${ISL_FOLDER_NAME}" \
        "${ISL_FOLDER_NAME}"

    )
    touch "${isl_stamp_file_path}"

  else
    echo "Library isl already installed."
  fi
}

function do_libelf()
{
  # http://www.mr511.de/ (?Deprecated?)
  # http://www.mr511.de/software/
  # https://sourceware.org/elfutils/
  # ftp://sourceware.org/pub/elfutils//0.178/elfutils-0.178.tar.bz2

  # https://archlinuxarm.org/packages/aarch64/libelf/files/PKGBUILD

  # LIBELF_VERSION="0.8.13" (deprecated)
  # 26 Nov 2019, 0.178


  LIBELF_FOLDER_NAME="libelf-${LIBELF_VERSION}"
  local libelf_archive="${LIBELF_FOLDER_NAME}.tar.gz"

  # local libelf_url="http://www.mr511.de/software/${libelf_archive}"
  # The original site seems unavailable, use a mirror.
  local libelf_url="https://fossies.org/linux/misc/old/${libelf_archive}"

  local libelf_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libelf-${LIBELF_VERSION}-installed"
  if [ ! -f "${libelf_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libelf_url}" "${libelf_archive}" "${LIBELF_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${LIBELF_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${LIBELF_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-tautological-compare"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then 
        (
          echo
          echo "Running libelf configure..."

          bash "${SOURCES_FOLDER_PATH}/${LIBELF_FOLDER_NAME}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${LIBELF_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --disable-nls

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libelf-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libelf-output.txt"
      fi

      (
        echo
        echo "Running libelf make..."

        # Build.
        make -j ${JOBS}

        if [ "${WITH_TESTS}" == "y" ]
        then
          make check
        fi

        make install
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libelf-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${LIBELF_FOLDER_NAME}" \
        "${LIBELF_FOLDER_NAME}"

    )

    touch "${libelf_stamp_file_path}"

  else
    echo "Library libelf already installed."
  fi
}

function do_expat()
{
  # https://libexpat.github.io
  # https://github.com/libexpat/libexpat/releases

  # https://archlinuxarm.org/packages/aarch64/expat/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=expat-git

  # Oct 21, 2017 "2.1.1"
  # Nov 1, 2017 "2.2.5"
  # 26 Sep 2019 "2.2.9"

  EXPAT_FOLDER_NAME="expat-${EXPAT_VERSION}"
  local expat_archive="${EXPAT_FOLDER_NAME}.tar.bz2"
  if [[ "${EXPAT_VERSION}" =~ 2\.0\.* ]]
  then
    expat_archive="${EXPAT_FOLDER_NAME}.tar.gz"
  fi
  
  local expat_release="R_$(echo ${EXPAT_VERSION} | sed -e 's|[.]|_|g')"
  local expat_url="https://github.com/libexpat/libexpat/releases/download/${expat_release}/${expat_archive}"

  local expat_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-expat-${EXPAT_VERSION}-installed"
  if [ ! -f "${expat_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${expat_url}" "${expat_archive}" "${EXPAT_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${EXPAT_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${EXPAT_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then 
        (
          echo
          echo "Running expat configure..."

          bash "${SOURCES_FOLDER_PATH}/${EXPAT_FOLDER_NAME}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${EXPAT_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            
          cp "config.log" "${LOGS_FOLDER_PATH}/config-expat-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-expat-output.txt"
      fi

      (
        echo
        echo "Running expat make..."

        # Build.
        make -j ${JOBS}

        if [ "${WITH_TESTS}" == "y" ]
        then
          make check
        fi

        make install
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-expat-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${EXPAT_FOLDER_NAME}" \
        "${EXPAT_FOLDER_NAME}"

    )

    touch "${expat_stamp_file_path}"

  else
    echo "Library expat already installed."
  fi
}

function do_libiconv()
{
  # https://www.gnu.org/software/libiconv/
  # https://ftp.gnu.org/pub/gnu/libiconv/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libiconv

  # 2011-08-07 1.14"
  # 2017-02-02 "1.15"
  # 2019-04-26 "1.16"

  LIBICONV_FOLDER_NAME="libiconv-${LIBICONV_VERSION}"
  local libiconv_archive="${LIBICONV_FOLDER_NAME}.tar.gz"
  local libiconv_url="https://ftp.gnu.org/pub/gnu/libiconv/${libiconv_archive}"

  local libiconv_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libiconv-${LIBICONV_VERSION}-installed"
  if [ ! -f "${libiconv_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libiconv_url}" "${libiconv_archive}" "${LIBICONV_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CPPFLAGS="${XBB_CPPFLAGS}"
      # -fgnu89-inline fixes "undefined reference to `aliases2_lookup'"
      #  https://savannah.gnu.org/bugs/?47953
      export CFLAGS="${XBB_CFLAGS} -fgnu89-inline -Wno-tautological-compare -Wno-parentheses-equality -Wno-static-in-inline -Wno-pointer-to-int-cast"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then 
        (
          echo
          echo "Running libiconv configure..."

          bash "${SOURCES_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --disable-nls

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libiconv-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libiconv-output.txt"
      fi

      (
        echo
        echo "Running libiconv make..."

        # Build.
        make -j ${JOBS}

        if [ "${WITH_TESTS}" == "y" ]
        then
          make check
        fi

        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libiconv-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}" \
        "${LIBICONV_FOLDER_NAME}"

    )

    touch "${libiconv_stamp_file_path}"

  else
    echo "Library libiconv already installed."
  fi
}

function do_xz()
{
  # https://tukaani.org/xz/
  # https://sourceforge.net/projects/lzmautils/files/

  # https://archlinuxarm.org/packages/aarch64/xz/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=xz-git

  # 2016-12-30 "5.2.3"
  # 2018-04-29 "5.2.4"

  XZ_FOLDER_NAME="xz-${XZ_VERSION}"
  local xz_archive="${XZ_FOLDER_NAME}.tar.xz"
  local xz_url="https://sourceforge.net/projects/lzmautils/files/${xz_archive}"

  local xz_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-xz-${XZ_VERSION}-installed"
  if [ ! -f "${xz_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${xz_url}" "${xz_archive}" "${XZ_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${XZ_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${XZ_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-implicit-fallthrough"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then 
        (
          echo
          echo "Running xz configure..."

          bash "${SOURCES_FOLDER_PATH}/${XZ_FOLDER_NAME}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${XZ_FOLDER_NAME}/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --disable-rpath \
            --disable-nls

          cp "config.log" "${LOGS_FOLDER_PATH}/config-xz-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-xz-output.txt"
      fi

      (
        echo
        echo "Running xz make..."

        # Build.
        make -j ${JOBS}

        if [ "${WITH_TESTS}" == "y" ]
        then
          make check
        fi

        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-xz-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${XZ_FOLDER_NAME}" \
        "${XZ_FOLDER_NAME}"

    )

    touch "${xz_stamp_file_path}"

  else
    echo "Library xz already installed."
  fi
}

# Not used.
function do_gettext() 
{
  # https://www.gnu.org/software/gettext/
  # http://ftp.gnu.org/pub/gnu/gettext/

  # https://archlinuxarm.org/packages/aarch64/gettext/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gettext-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gettext

  # GETTEXT_VERSION="0.19.5.1"
  # 2016-06-11 "0.19.8.1"
  # 2019-05-12 "0.20.1"

  GETTEXT_SRC_FOLDER_NAME="gettext-${GETTEXT_VERSION}"
  GETTEXT_FOLDER_NAME="${GETTEXT_SRC_FOLDER_NAME}"
  local gettext_archive="${GETTEXT_SRC_FOLDER_NAME}.tar.gz"
  local gettext_url="http://ftp.gnu.org/pub/gnu/gettext/${gettext_archive}"

  local gettext_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-gettext-${GETTEXT_VERSION}-installed"
  if [ ! -f "${gettext_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gettext_url}" "${gettext_archive}" \
      "${GETTEXT_SRC_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${GETTEXT_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${GETTEXT_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      if [ "${TARGET_PLATFORM}" != "darwin" ]
      then
        export CFLAGS="${CFLAGS} -Wno-discarded-qualifiers -Wno-incompatible-pointer-types -Wno-attributes -Wno-unknown-warning-option"
      fi
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"
      
      if [ ! -f "config.status" ]
      then 

        (
          echo
          echo "Running gettext configure..."

          if [ "${TARGET_PLATFORM}" == "win32" ]
          then
            THREADS="windows"
          elif [ "${TARGET_PLATFORM}" == "linux" ]
          then
            THREADS="posix"
          elif [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            THREADS="posix"
          fi

          # Build only the /gettext-runtime folder, attempts to build
          # the full package fail with a CXX='no' problem.
          bash "${SOURCES_FOLDER_PATH}/${GETTEXT_SRC_FOLDER_NAME}/gettext-runtime/configure" --help

          #  --enable-nls needed to include libintl
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${GETTEXT_SRC_FOLDER_NAME}/gettext-runtime/configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --disable-shared \
            --enable-static \
            --enable-threads=${THREADS} \
            --with-gnu-ld \
            --disable-installed-tests \
            --disable-always-build-tests \
            --enable-nls \
            --disable-rpath \
            --disable-java \
            --disable-native-java \
            --disable-c++ \
            --disable-libasprintf

          cp "config.log" "${LOGS_FOLDER_PATH}/config-gettext-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gettext-output.txt"

      fi

      (
        echo
        echo "Running gettext make..."

        # Build.
        make -j ${JOBS}

        if [ "${WITH_TESTS}" == "y" ]
        then
          make check # || true
        fi

        # Avoid strip here, it may interfere with patchelf.
        # make install-strip
        make install

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gettext-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${GETTEXT_FOLDER_NAME}" \
        "${GETTEXT_FOLDER_NAME}"

    )

    touch "${gettext_stamp_file_path}"

  else
    echo "Library gettext already installed."
  fi
}

# Not functional on windows.
function do_ncurses()
{
  # https://invisible-island.net/ncurses/
  # ftp://ftp.invisible-island.net/pub/ncurses
  # ftp://ftp.invisible-island.net/pub/ncurses/ncurses-6.2.tar.gz

  # https://archlinuxarm.org/packages/aarch64/ncurses/files/PKGBUILD

  # _4421.c:1364:15: error: expected ‘)’ before ‘int’
  # ../include/curses.h:1906:56: note: in definition of macro ‘mouse_trafo’
  # 1906 | #define mouse_trafo(y,x,to_screen) wmouse_trafo(stdscr,y,x,to_screen)

  # 26 Feb 2011, "5.8" # build fails
  # 27 Jan 2018, "5.9" # build fails
  # 27 Jan 2018, "6.1"
  # 12 Feb 2020, "6.2"

  NCURSES_FOLDER_NAME="ncurses-${NCURSES_VERSION}"
  local ncurses_archive="${NCURSES_FOLDER_NAME}.tar.gz"
  local ncurses_url="ftp://ftp.invisible-island.net//pub/ncurses/${ncurses_archive}"

  local ncurses_version_major="$(echo ${NCURSES_VERSION} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)|\1|')"
  local ncurses_version_minor="$(echo ${NCURSES_VERSION} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)|\2|')"

  local ncurses_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-ncurses-${NCURSES_VERSION}-installed"
  if [ ! -f "${ncurses_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${ncurses_url}" "${ncurses_archive}" "${NCURSES_FOLDER_NAME}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${NCURSES_FOLDER_NAME}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${NCURSES_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then 
        (
          echo
          echo "Running ncurses configure..."

          bash "${SOURCES_FOLDER_PATH}/${NCURSES_FOLDER_NAME}/configure" --help

          # Not yet functional on windows.
          if [ "${TARGET_PLATFORM}" == "win32" ]
          then

            # export PATH_SEPARATOR=";"

            # Without --with-pkg-config-libdir= it'll try to write the .pc files in the
            # xbb folder, probbaly by using the dirname of pkg-config.
            bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${NCURSES_FOLDER_NAME}/configure" \
              --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
              \
              --build=${BUILD} \
              --host=${HOST} \
              --target=${TARGET} \
              --with-build-cc=${CC} \
              --with-build-cflags=${CFLAGS} \
              --with-build-cppflags=${CPPFLAGS} \
              --with-build-ldflags=${LDFLAGS} \
              \
              --with-shared \
              --with-normal \
              --with-cxx \
              --with-cxx-binding \
              --with-cxx-shared \
              --with-pkg-config-libdir="${LIBS_INSTALL_FOLDER_PATH}/lib/pkgconfig" \
              --without-ada \
              --without-debug \
              --without-manpage \
              --without-prog \
              \
              --enable-assertions \
              --enable-sp-funcs \
              --enable-term-driver \
              --enable-interop \
              --enable-pc-files \
              --disable-termcap \
              --disable-home-terminfo \

          else

            # Without --with-pkg-config-libdir= it'll try to write the .pc files in the
            # xbb folder, probbaly by using the dirname of pkg-config.
            bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${NCURSES_FOLDER_NAME}/configure" \
              --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
              \
              --build=${BUILD} \
              --host=${HOST} \
              --target=${TARGET} \
              \
              --with-shared \
              --with-normal \
              --with-cxx \
              --with-cxx-binding \
              --with-cxx-shared \
              --with-pkg-config-libdir="${LIBS_INSTALL_FOLDER_PATH}/lib/pkgconfig" \
              --with-terminfo-dirs=/usr/share/terminfo \
              --with-default-terminfo-dir=/usr/share/terminfo \
              --with-gpm \
              --without-debug \
              --without-ada \
              --without-manpage \
              --without-prog \
              \
              --enable-widec \
              --enable-pc-files \
              --enable-termcap \
              --enable-ext-colors \

          fi

          cp "config.log" "${LOGS_FOLDER_PATH}/config-ncurses-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-ncurses-output.txt"
      fi

      (
        echo
        echo "Running ncurses make..."

        # Build.
        make -j ${JOBS}

        # The test-programs are interactive

        # make install-strip
        make install

        # fool packages looking to link to non-wide-character ncurses libraries
        for lib in ncurses ncurses++ form panel menu; do
          echo "INPUT(-l${lib}w)" > "${LIBS_INSTALL_FOLDER_PATH}/lib/lib${lib}.so"
          rm -f "${LIBS_INSTALL_FOLDER_PATH}/lib/pkgconfig/${lib}.pc"
          ln -s -v ${lib}w.pc "${LIBS_INSTALL_FOLDER_PATH}/lib/pkgconfig/${lib}.pc"
        done

        for lib in tic tinfo; do
          echo "INPUT(libncursesw.so.${ncurses_version_major})" > "${LIBS_INSTALL_FOLDER_PATH}/lib/lib${lib}.so"
          rm -f "${LIBS_INSTALL_FOLDER_PATH}/lib/lib${lib}.so.${ncurses_version_major}"
          ln -s -v libncursesw.so.${ncurses_version_major} "${LIBS_INSTALL_FOLDER_PATH}/lib/lib${lib}.so.${ncurses_version_major}"
          rm -f "${LIBS_INSTALL_FOLDER_PATH}/lib/pkgconfig/${lib}.pc"
          ln -s -v ncursesw.pc "${LIBS_INSTALL_FOLDER_PATH}/lib/pkgconfig/${lib}.pc"
        done

        # some packages look for -lcurses during build
        echo 'INPUT(-lncursesw)' > "${LIBS_INSTALL_FOLDER_PATH}/lib/libcursesw.so"
        rm -f "${LIBS_INSTALL_FOLDER_PATH}/lib/libcurses.so"
        ln -s -v libncurses.so "${LIBS_INSTALL_FOLDER_PATH}/lib/libcurses.so"

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-ncurses-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${NCURSES_FOLDER_NAME}" \
        "${NCURSES_FOLDER_NAME}"

    )

    touch "${ncurses_stamp_file_path}"

  else
    echo "Library ncurses already installed."
  fi
}

function do_gpm()
{
  # https://www.nico.schottelius.org/software/gpm/
  # https://github.com/telmich/gpm
  # https://github.com/telmich/gpm/releases/tag/1.20.7
  # https://github.com/telmich/gpm/archive/1.20.7.tar.gz

  # https://archlinuxarm.org/packages/aarch64/gpm/files/PKGBUILD

  # 27 Oct 2012 "1.20.7"

  GPM_FOLDER_NAME="gpm-${GPM_VERSION}"
  local gpm_archive="${GPM_FOLDER_NAME}.tar.gz"
  local gpm_github_archive="${GPM_VERSION}.tar.gz"
  
  local gpm_url="https://github.com/telmich/gpm/archive/${gpm_github_archive}"

  local gpm_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-gpm-${GPM_VERSION}-installed"
  if [ ! -f "${gpm_stamp_file_path}" ]
  then

    cd "${LIBS_BUILD_FOLDER_PATH}"

    download_and_extract "${gpm_url}" "${gpm_archive}" "${GPM_FOLDER_NAME}"

    (
      cd "${LIBS_BUILD_FOLDER_PATH}/${GPM_FOLDER_NAME}"
      if [ ! -f "stamp-autogen" ]
      then

        xbb_activate
        
        run_app bash ${DEBUG} "autogen.sh"

        touch "stamp-autogen"
      fi
    ) 2>&1 | tee "${LOGS_FOLDER_PATH}/autogen-gpm-output.txt"

    (
      cd "${LIBS_BUILD_FOLDER_PATH}/${GPM_FOLDER_NAME}"

      xbb_activate
      xbb_activate_installed_dev

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then 
        (
          echo
          echo "Running gpm configure..."

          bash "configure" --help

          bash ${DEBUG} "configure" \
            --prefix="${LIBS_INSTALL_FOLDER_PATH}" \
            \
            --build=${BUILD} \
            --host=${HOST} \
            --target=${TARGET} \
            \
            --with-pic \
            
          cp "config.log" "${LOGS_FOLDER_PATH}/config-gpm-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gpm-output.txt"
      fi

      (
        echo
        echo "Running gpm make..."

        # Build.
        make -j ${JOBS}

        if [ "${WITH_TESTS}" == "y" ]
        then
          make check
        fi

        make install

        if [ "${TARGET_PLATFORM}" == "linux" ]
        then
          # Manual copy, since it is not refered in the elf.
          cp -v "${LIBS_INSTALL_FOLDER_PATH}/lib/libgpm.so.2.1.0" "${APP_PREFIX}/bin"
          rm -f "${APP_PREFIX}/bin/libgpm.so.2"
          ln -s -v "${LIBS_INSTALL_FOLDER_PATH}/lib/libgpm.so.2.1.0" "${APP_PREFIX}/bin/libgpm.so.2"
        fi

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gpm-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${GPM_FOLDER_NAME}" \
        "${GPM_FOLDER_NAME}"
    )

    touch "${gpm_stamp_file_path}"

  else
    echo "Library gpm already installed."
  fi
}

# -----------------------------------------------------------------------------
