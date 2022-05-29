# Change & release log

Entries in this file are in reverse chronological order.

## 2022-05-29

- v11.2.1-1.2.1 published on npmjs.com
- v11.2.1-1.2 released

## 2022-05-28

- v11.2.1-1.2 prepared
- `--with-expat` added to GDB

## 2022-05-16

- v11.2.1-1.1.1 published on npmjs.com
- v11.2.1-1.1 released

## 2022-04-26

- v11.2.1-1.1 prepared

## 2021-11-17

- v10.3.1-2.3.1 published on npmjs.com
- v10.3.1-2.3 released
- v10.3.1-2.3 prepared, trying to add Apple Silicon support

## 2021-11-12

- v10.3.1-2.2.1 published on npmjs.com
- v10.3.1-2.2 released

## 2021-11-11

- v10.3.1-2.2 prepared

## 2021-10-24

- v10.3.1-2.1.1 published on npmjs.com
- v10.3.1-2.1 released
- `-D__USE_MINGW_ACCESS` used to fix mingw `access()` issue

## 2021-10-22

- v10.3.1-2.1 prepared from 2021.10
- v10.3.1-1.1 prepared from 2021.07, but no longer released

## 2021-10-04

- update for new helper & XBB v3.3

## 2020-12-19

- v10.2.1-1.1.2 published on npmjs.com
- v10.2.1-1.1 released

## 2020-10-23

- v9.3.1-1.4.1 published on npmjs.com
- v9.3.1-1.4 released

## 2020-10-20

- v9.3.1-1.4 prepared

## 2020-10-12

- v9.3.1-1.3.1 published on npmjs.com
- v9.3.1-1.3 released

## 2020-10-11

- v9.3.1-1.3 prepared

## 2020-08-27

- v9.3.1-1.2.1 published on npmjs.com
- v9.3.1-1.2 released

## 2020-08-26

- v9.3.1-1.2 prepared
- [#7] fix libstdc++ ignored exceptions
- remove --disable-rpath

## 2020-07-03

- v9.3.1-1.1.1 published on npmjs.com
- v9.3.1-1.1 released

## 2019-12-11

- v9.2.1-1.2 prepared
- add support for native builds and arm64/armv7l targets
- add support for TUI in GDB

## 2019-12-06

- v8.3.1-1.4.1 published on npmjs.com
- v9.2.1-1.1.1 published on npmjs.com

## 2019-12-05

- v9.2.1-1.1 released

## 2019-12-04

- v8.3.1-1.4 released, as a repack of 1.3 with single folder content

## 2019-11-02

- v8.3.1-1.3 released
- v8.3.1-1.3 published on npmjs.com

## 2019-10-22

- v8.3.1-1.3 prepared

## 2019-10-16

- [#4] fix Windows gdb-py, by removing the python27.dll
- [#3] fix macOS gdb-py, by using the Apple Python during the build

## 2019-10-11

- v8.3.1-1.2 released
- v8.3.1-1.2 published on npmjs.com

## 2019-10-07

- [#1] fix no-op libgcov (--with-native-system-header-dir)

## 2019-07-29

- v8.3.1-1.1 released
- v8.3.1-1.1.1 published on npmjs.com

## 2019-07-26

- v7.3.1-1.2 released
- v7.3.1-1.2.2 published on npmjs.com

___

# Historical GNU MCU Eclipse change log

## 2019-05-24

- v8.2.1-1.7 released
- reorder patch & strip, to avoid the bug in gcc make that
  creates illegal links

## 2019-05-10

- v8.2.1-1.6 released
- use Git GDB 8.3.50, 2019-05-09

## 2019-04-26

- v8.2.1-1.5 released

## 2019-03-25

- v8.2.1-1.5 pre-release
- add Python3 support for GNU/Linux & macOS
- with Windows LTO fixed

## 2019-02-14

- v8.2.1-1.4-20190214 released
- Windows LTO with -g gcc bug patched (libiberty)
- Windows with spaces in path bug patched

## 2019-02-02

- v8.2.1-1.3-20190202 released
- use Git GDB to fix LTO bugs
- remove the static options for the liblto_plugin-0.dll to be created
- link/copy the liblto_plugin to the bdf-plugins

## 2019-01-19

- v8.2.1-1.2-20190119 released
- 32-bit objcopy bug patched

## 2019-01-02

- v8.2.1-1.1-20190102 released
- based on Arm `gcc-arm-none-eabi-8-2018-q4-major`

## 2018-07-24

- v7.3.1-1.1-20180724 released
- based on Arm `gcc-arm-none-eabi-7-2018-q2-update`

## 2018-04-01

- v7.2.1-1.1-20180401 released
- based on Arm `gcc-arm-none-eabi-7-2017-q4-major`

## 2018-03-31

- v6.3.1-1.1-20180331 released
- based on Arm `gcc-arm-none-eabi-6-2017-q2-update`
