## extras

These are several files copied from the original Arm distribution.

Although the names end with `-manifest.txt`, the contents are different:

- the `*-arm-gnu-toolchain-arm-none-eabi-abe-manifest.txt` files are the actual
  ABE manifests used during the Arm build; they were downloaded from the
  download page and renamed
- the `*-darwin-x86_64-arm-none-eabi-manifest.txt` were extracted from the
  `arm-gnu-toolchain-*-darwin-x86_64-arm-none-eabi.tar.xz` archive, and
  include the configurations used to build the various libraries and
  components

For updated content, see the release note for the relevant release, on:

- <https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads>
