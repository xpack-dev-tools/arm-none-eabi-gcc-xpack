#!/usr/bin/env bash
rm -rf "${HOME}/Downloads/arm-none-eabi-gcc-build.git"
git clone --recurse-submodules https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-build.git "${HOME}/Downloads/arm-none-eabi-gcc-build.git"
