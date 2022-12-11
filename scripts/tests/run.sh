# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function tests_run_all()
{
  local test_bin_path="$1"

  # XBB_GCC_VERSION="$(echo "${XBB_RELEASE_VERSION}" | sed -e 's|-.*||')"
  # XBB_GCC_VERSION_MAJOR=$(echo ${XBB_GCC_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  test_binutils_cross "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}"

  test_cross_gcc "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}"

  test_cross_gdb "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}"

  test_cross_gdb "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}" "-py3"
}

function _tests_update_system()
{
  local image_name="$1"

  # Make sure that the minimum prerequisites are met.
  if [[ ${image_name} == github-actions-ubuntu* ]]
  then
    : # sudo apt-get -qq install -y XXX
  elif [[ ${image_name} == *ubuntu* ]] || [[ ${image_name} == *debian* ]] || [[ ${image_name} == *raspbian* ]]
  then
    run_verbose apt-get -qq update
    run_verbose apt-get -qq install -y git-core curl tar gzip lsb-release binutils
    run_verbose apt-get -qq install -y libc6-dev libstdc++6 # TODO: get rid of them
  elif [[ ${image_name} == *centos* ]] || [[ ${image_name} == *redhat* ]] || [[ ${image_name} == *fedora* ]]
  then
    run_verbose yum install -y -q git curl tar gzip redhat-lsb-core binutils which
    run_verbose yum install -y -q glibc-devel glibc-static libstdc++-devel # TODO: get rid of them
  elif [[ ${image_name} == *suse* ]]
  then
    run_verbose zypper -q --no-gpg-checks in -y git-core curl tar gzip lsb-release binutils findutils util-linux
    run_verbose zypper -q --no-gpg-checks in -y glibc-devel glibc-devel-static libstdc++6 # TODO: get rid of them
  elif [[ ${image_name} == *manjaro* ]]
  then
    # run_verbose pacman-mirrors -g
    run_verbose pacman -S -y -q --noconfirm

    # Update even if up to date (-yy) & upgrade (-u).
    # pacman -S -yy -u -q --noconfirm
    run_verbose pacman -S -q --noconfirm --noprogressbar git curl tar gzip lsb-release binutils which
    run_verbose pacman -S -q --noconfirm --noprogressbar gcc-libs # TODO: get rid of them
  elif [[ ${image_name} == *archlinux* ]]
  then
    run_verbose pacman -S -y -q --noconfirm

    # Update even if up to date (-yy) & upgrade (-u).
    # pacman -S -yy -u -q --noconfirm
    run_verbose pacman -S -q --noconfirm --noprogressbar git curl tar gzip lsb-release binutils which
    run_verbose pacman -S -q --noconfirm --noprogressbar gcc-libs
  fi

  echo
  echo "The system C/C++ libraries..."
  find /usr/lib* /lib -name 'libc.*' -o -name 'libstdc++.*' -o -name 'libgcc_s.*'
}

# -----------------------------------------------------------------------------
