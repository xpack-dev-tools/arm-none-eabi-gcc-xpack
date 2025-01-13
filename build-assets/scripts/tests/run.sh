# -----------------------------------------------------------------------------
#
# This file is part of the xPack project (http://xpack.github.io).
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
#
# If a copy of the license was not distributed with this file, it can
# be obtained from https://opensource.org/licenses/mit/.
#
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
