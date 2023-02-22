## arm-f4b-fs

Freestanding blinky for STM32F4DISCOVERY, with and without LTO.

Note: The POSIX case does not pass the link with LTO. To be investigated.

### Compiler test

Build all three configurations:

- Debug
- Debug-lto
- Release
- Release-lto

The results should look like:

```console
Invoking: GNU ARM Cross Print Size
arm-none-eabi-size --format=berkeley "f4b-fs.elf"
   text	   data	    bss	    dec	    hex	filename
   8759	    164	    496	   9419	   24cb	f4b-fs.elf
Finished building: f4b-fs.siz

Invoking: GNU ARM Cross Print Size
arm-none-eabi-size --format=berkeley "f4b-fs.elf"
   text	   data	    bss	    dec	    hex	filename
   8716	    164	    496	   9376	   24a0	f4b-fs.elf
Finished building: f4b-fs.siz


Invoking: GNU ARM Cross Print Size
arm-none-eabi-size --format=berkeley "f4b-fs.elf"
   text	   data	    bss	    dec	    hex	filename
   3724	     56	    332	   4112	   1010	f4b-fs.elf
Finished building: f4b-fs.siz

Invoking: GNU ARM Cross Print Size
arm-none-eabi-size --format=berkeley "f4b-fs.elf"
   text	   data	    bss	    dec	    hex	filename
   2188	     48	    328	   2564	    a04	f4b-fs.elf
Finished building: f4b-fs.siz
```

### Debugger test

Run the `f4b-fs-debug-qemu` and `f4b-fs-debug-lto-qemu` launcher.

If the physical board is available, run the `f4b-fs-debug-oocd.launch` too.
