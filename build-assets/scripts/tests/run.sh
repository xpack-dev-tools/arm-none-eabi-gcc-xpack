# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function tests_run_all()
{
  echo
  echo "[${FUNCNAME[0]} $@]"

  local test_bin_path="$1"

  binutils_cross_test "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}"

  gcc_cross_test "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}"

  gdb_cross_test "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}"

  gdb_cross_test "${test_bin_path}" "${XBB_APPLICATION_TARGET_TRIPLET}" "-py3"
}

# -----------------------------------------------------------------------------
