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

base_url="undefined"

has_gdb_py="y"
has_gdb_py3="y"

while [ $# -gt 0 ]
do
  case "$1" in

    --base-url)
      shift
      base_url="$1"
      shift
      ;;

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

work_folder_absolute_path="${HOME}/Work"
repo_folder_absolute_path="${TRAVIS_BUILD_DIR}"
cache_absolute_folder_path="${work_folder_absolute_path}/cache"

gcc_target="arm-none-eabi"
version="$(cat ${repo_folder_absolute_path}/scripts/VERSION)"

# -----------------------------------------------------------------------------

detect_architecture

# TODO: add support for Windows .zip.
archive_name="xpack-${gcc_target}-gcc-${version}-${uname_platform}-${node_architecture}.tar.gz"
archive_folder_name="xpack-${gcc_target}-gcc-${version}"

node_platform="${uname_platform}"

# -----------------------------------------------------------------------------

mkdir -p "${cache_absolute_folder_path}"

if [ ! -f "${cache_absolute_folder_path}/${archive_name}" ]
then
  echo
  echo "Downloading ${archive_name}..."
  curl -L --fail -o "${cache_absolute_folder_path}/${archive_name}" \
    ${base_url}/${archive_name}
fi

# In the container user home.
test_absolute_folder_path="${HOME}/test-arm-none-eabi-gcc"

mkdir -p "${test_absolute_folder_path}"
cd "${test_absolute_folder_path}"

echo
echo "Extracting ${archive_name}..."
if [[ "${archive_name}" == *.zip ]]
then
  unzip -q "${cache_absolute_folder_path}/${archive_name}"
else 
  tar xf "${cache_absolute_folder_path}/${archive_name}"
fi

app_absolute_folder_path="${test_absolute_folder_path}/${archive_folder_name}"

ls -lL "${app_absolute_folder_path}"

# -----------------------------------------------------------------------------

run_binutils

run_gcc

run_gdb

if [ "${has_gdb_py}" == "y" ]
then
  run_gdb "-py"
fi

if [ "${has_gdb_py3}" == "y" ]
then
  run_gdb "-py3"
fi

echo
echo "All tests completed successfully."

echo
run_app uname -a
if [ "${node_platform}" == "linux" ]
then
  run_app lsb_release -a
  run_app ldd --version
elif [ "${node_platform}" == "darwin" ]
then
  run_app sw_vers
fi

# Completed successfully.
exit 0

# -----------------------------------------------------------------------------
