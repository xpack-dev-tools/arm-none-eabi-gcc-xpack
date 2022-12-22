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

  test_binutils_cross "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}"

  test_cross_gcc "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}"

  test_cross_gdb "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}"

  test_cross_gdb "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}" "-py3"
}

# -----------------------------------------------------------------------------
