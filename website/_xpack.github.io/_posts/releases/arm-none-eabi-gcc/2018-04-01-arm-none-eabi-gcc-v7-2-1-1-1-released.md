---

title:  GNU MCU Eclipse ARM Embedded GCC v7.2.1-1.1 released
sidebar: arm-none-eabi-gcc

summary: "Version **7.2.1-1.1** is a new release of **GNU MCU Eclipse ARM Embedded GCC**."
app_name: "GNU MCU Eclipse ARM Embedded GCC"

download_url: https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc/releases/tag/v7.2.1-1.1/

date: 2018-04-01 21:18:00 +0300

redirect_to: https://xpack-dev-tools.github.io/arm-none-eabi-gcc-xpack/blog/2018/04/01/arm-none-eabi-gcc-v7-2-1-1-1-released/

comments: true

categories:
  - releases
  - arm-none-eabi-gcc

tags:
  - releases
  - arm
  - arm-none-eabi-gcc
  - gcc
  - binaries

---

## Download

The binary files are available from [GitHub Releases]({{ page.download_url }}).

## Compliance

This release follows the official [GNU Arm Embedded Toolchain](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm)  **7-2017-q4-major** release from December 18, 2017 and it is based on the `gcc-arm-none-eabi-7-2017-q4-major-src.tar.bz2` source invariant.

## Binaries

Binaries for **Windows**, **macOS** and **GNU/Linux** are provided.

The GNU/Linux binaries were built on two CentOS 6 Docker images (32/64-bit), and run on any distribution based on CentOS 6 or later.

The macOS binary was built on a macOS 10.10.5 and must run on any newer macOS system.

The Windows binaries were built with mingw-w64, and run on any reasonably recent **i686** and **x86_64** Windows machines.

Instructions on how to install the binaries are available in the separate [How to install the ARM toolchain?]({{ site.baseurl }}/dev-tools/arm-none-eabi-gcc/install/) page.

The toolchain is also available as an [xPack](https://www.npmjs.com/package/@gnu-mcu-eclipse/arm-none-eabi-gcc) and can be conveniently installed with [`xpm`](https://www.npmjs.com/package/xpm):

```sh
xpm install --global @gnu-mcu-eclipse/arm-none-eabi-gcc@latest
```

This installs the latest available version.

For better control and repeatability, the build scripts use Docker containers; all files required during builds are available as a separate [gnu-mcu-eclipse/arm-none-eabi-gcc-build](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-build) project.

## Known problems

* none

## Checksums

The SHA-256 hashes for the files are:

```txt
1d9f4bfcae98681c13791781a3c30272fecf316d0e63dd560f9df437bde34a55 ?
gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-centos32.tgz

47d1f10375b7ff6b0a8129f2cccf17193b967a3803b2896db55cffb7766678fe ?
gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-centos64.tgz

a41ea58d5e2ec632af80f9e2600d43c582f0cb422e06852475c05642694b51c8 ?
gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-osx.tgz

578c4525187c498ec0b8255ac46d4177ed3b51b115cb6ca4cd379baa6b70db7a ?
gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-win32.zip

fd9573d0b9e89d87b9bf7f237955bbeba206a93c6cecc2fc3996458798d7a05b ?
gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-win64.zip
```
