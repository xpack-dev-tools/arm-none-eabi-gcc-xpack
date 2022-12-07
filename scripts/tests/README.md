# Scripts to test the Arm Embedded GCC xPack

The binaries can be available from one of the pre-releases:

<https://github.com/xpack-dev-tools/pre-releases/releases>

## Download the repo

The test script is part of the Arm Embedded GCC xPack:

```sh
rm -rf  ~/Work/arm-none-eabi-gcc-xpack.git && \
mkdir -p ~/Work && \
git clone \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack.git  \
   ~/Work/arm-none-eabi-gcc-xpack.git && \
git -C ~/Work/arm-none-eabi-gcc-xpack.git submodule update --init --recursive
```

## Start a local test

To check if Arm Embedded GCC starts on the current platform, run a native test:

```sh
bash ~/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/tests/native-test.sh \
  --base-url "https://github.com/xpack-dev-tools/pre-releases/releases/download/test/"
```

The script stores the downloaded archive in a local cache, and
does not download it again if available locally.

To force a new download, remove the local archive:

```sh
rm -rf ~/Work/cache/xpack-arm-none-eabi-gcc-[0-9]*-*
```

## Start the GitHub Actions tests

The multi-platform tests run on GitHub Actions; they do not fire on
git commits, but only via a manual POST to the GitHub API.

```sh
bash ~/Work/arm-none-eabi-gcc-xpack.git/scripts/tests/trigger-workflow-test-native.sh \
  --branch xpack-develop \
  --base-url "https://github.com/xpack-dev-tools/pre-releases/releases/download/test/"

bash ~/Work/arm-none-eabi-gcc-xpack.git/scripts/tests/trigger-workflow-test-docker-linux-intel.sh \
  --branch xpack-develop \
  --base-url "https://github.com/xpack-dev-tools/pre-releases/releases/download/test/"

bash ~/Work/arm-none-eabi-gcc-xpack.git/scripts/tests/trigger-workflow-test-docker-linux-arm.sh \
  --branch xpack-develop \
  --base-url "https://github.com/xpack-dev-tools/pre-releases/releases/download/test/"

```

The results are available at the project
[Actions](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/actions/) page.
