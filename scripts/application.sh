# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Application specific definitions. Included with source.

# Used to display the application name.
XBB_APPLICATION_NAME=${XBB_APPLICATION_NAME:-"GNU Arm Embedded GCC"}

# Used as part of file/folder paths.
XBB_APPLICATION_LOWER_CASE_NAME=${XBB_APPLICATION_LOWER_CASE_NAME:-"arm-none-eabi-gcc"}

XBB_APPLICATION_DISTRO_NAME=${XBB_APPLICATION_DISTRO_NAME:-"xPack"}
XBB_APPLICATION_DISTRO_LOWER_CASE_NAME=${XBB_APPLICATION_DISTRO_LOWER_CASE_NAME:-"xpack"}
XBB_APPLICATION_DISTRO_TOP_FOLDER=${XBB_APPLICATION_DISTRO_TOP_FOLDER:-"xPacks"}

XBB_APPLICATION_DESCRIPTION="${XBB_APPLICATION_DISTRO_NAME} ${XBB_APPLICATION_NAME}"

declare -a XBB_APPLICATION_DEPENDENCIES=( )
declare -a XBB_APPLICATION_COMMON_DEPENDENCIES=( texinfo zlib gmp mpfr mpc isl libiconv xz zstd binutils-cross gcc-cross newlib-cross expat gettext gpm ncurses readline bzip2 libffi mpdecimal sqlite libxcrypt openssl python3 libunistring gdb-cross )

XBB_APPLICATION_HAS_FLEX_PACKAGE="y"

# XBB_APPLICATION_USE_CLANG_ON_LINUX="y"

# Unfortunately libtool creates shared libraries that use the gcc libraries.
# XBB_APPLICATION_USE_CLANG_LIBCXX="y"

# -----------------------------------------------------------------------------

XBB_APPLICATION_TARGET_TRIPLET=${XBB_APPLICATION_TARGET_TRIPLET:-"arm-none-eabi"}

# -----------------------------------------------------------------------------

# Normally should be commented out. Enable it only during tests,
# to save some build time.
XBB_APPLICATION_WITHOUT_MULTILIB="y"

# -----------------------------------------------------------------------------

XBB_GITHUB_ORG="${XBB_GITHUB_ORG:-"xpack-dev-tools"}"
XBB_GITHUB_REPO="${XBB_GITHUB_REPO:-"${XBB_APPLICATION_LOWER_CASE_NAME}-xpack"}"
XBB_GITHUB_PRE_RELEASES="${XBB_GITHUB_PRE_RELEASES:-"pre-releases"}"

XBB_NPM_PACKAGE="${XBB_NPM_PACKAGE:-"@xpack-dev-tools/${XBB_APPLICATION_LOWER_CASE_NAME}@next"}"

# -----------------------------------------------------------------------------
