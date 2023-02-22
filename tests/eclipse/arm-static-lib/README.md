## arm-static-lib

Simple static library test, with and without LTO.

With LTO, the test checks if the `lto-plugin` is in the expected location.

### Compiler test

Build both configurations:

- Debug
- Debug-lto
- Release
- Release-lto

The result should look like:

```console
make all
Building file: ../lib.c
Invoking: GNU ARM Cross C Compiler
arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -std=gnu11 -MMD -MP -MF"lib.d" -MT"lib.o" -c -o "lib.o" "../lib.c"
Finished building: ../lib.c

Building target: libstatic-lib-lto.a
Invoking: GNU ARM Cross Archiver
arm-none-eabi-ar -r  "libstatic-lib-lto.a"  ./lib.o
arm-none-eabi-ar: creating libstatic-lib-lto.a
Finished building target: libstatic-lib-lto.a
```

If the LTO plugin is not available, `arm-none-eabi-ar` complains, but,
surprisingly, the build does not fail.

```console
Building target: libarm-static-lib.a
Invoking: GNU ARM Cross Archiver
arm-none-eabi-ar -r  "libarm-static-lib.a"  ./lib.o
arm-none-eabi-ar: creating libarm-static-lib.a
arm-none-eabi-ar: ./lib.o: plugin needed to handle lto object <---
Finished building target: libarm-static-lib.a
```

