#!/usr/bin/env bash
rm -rf "${HOME}/Downloads/arm-none-eabi-gcc-xpack.git"
git clone --recurse-submodules https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack.git "${HOME}/Downloads/arm-none-eabi-gcc-xpack.git"
