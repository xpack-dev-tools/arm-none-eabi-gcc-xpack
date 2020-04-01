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

image_name="$1"
echo "${image_name}"
shift

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

# -----------------------------------------------------------------------------

source "${script_folder_path}/common-functions-source.sh"

# -----------------------------------------------------------------------------

work_folder_absolute_path="/Host/Work"
repo_folder_absolute_path="/Host/repo"
cache_absolute_folder_path="${work_folder_absolute_path}/cache"

gcc_target="arm-none-eabi"
version="$(cat ${repo_folder_absolute_path}/scripts/VERSION)"

# -----------------------------------------------------------------------------

if [[ ${image_name} == ubuntu* ]] || [[ ${image_name} == debian* ]]
then
  apt-get -qq update 
  apt-get -qq install -y git-core curl tar gzip lsb-release
elif [[ ${image_name} == centos* ]]
then
  yum install -y git
elif [[ ${image_name} == opensuse* ]]
then
  zypper in -y git-core curl tar gzip lsb-release
fi

# -----------------------------------------------------------------------------

uname -a

uname_platform=$(uname -s | tr '[:upper:]' '[:lower:]')
uname_machine=$(uname -m | tr '[:upper:]' '[:lower:]')

node_architecture=""
if [ "${uname_machine}" == "x86_64" ]
then
  node_architecture="x64"
elif [ "${uname_machine}" == "i386" -o "${uname_machine}" == "i586" -o "${uname_machine}" == "i686" ]
then
  node_architecture="x64"
elif [ "${uname_machine}" == "aarch64" ]
then
  node_architecture="arm64"
elif [ "${uname_machine}" == "armv7l" -o "${uname_machine}" == "armv8l" ]
then
  node_architecture="arm"
else
  echo "${uname_machine} not supported"
  exit 1
fi

# TODO: add support for Windows.
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
run_app lsb_release -a
run_app ldd --version

# Completed successfully.
exit 0

# -----------------------------------------------------------------------------
