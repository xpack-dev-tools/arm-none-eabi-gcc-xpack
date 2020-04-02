#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Identify the script location, to reach, for example, the helper scripts.

script_path="$0"
if [[ "${script_path}" != /* ]]
then
  # Make relative path absolute.
  script_path="$(pwd)/$0"
fi

script_name="$(basename "${script_path}")"

script_folder_path="$(dirname "${script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

base_url="$1"
echo "${base_url}"
shift

has_gdb_py="y"
has_gdb_py3="y"

while [ $# -gt 0 ]
do
  case "$1" in

    --skip-gdb-py)
      has_gdb_py="n"
      shift
      ;;

    --skip-gdb-py3)
      has_gdb_py3="n"
      shift
      ;;

    -*)
      echo "Unsupported option $1."
      exit 1
      ;;

  esac
done

echo "${base_url}"

# -----------------------------------------------------------------------------

source "${script_folder_path}/common-functions-source.sh"

# -----------------------------------------------------------------------------

detect_architecture

prepare_env

install_archive

run_tests

# Completed successfully.
exit 0

# -----------------------------------------------------------------------------
