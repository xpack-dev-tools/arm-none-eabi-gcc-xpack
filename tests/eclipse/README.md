# Simple toolchain use tests

## arm-f4b-fs

Freestanding blinky for STM32F4DISCOVERY, with and without LTO.

Compiler and debugger (QEMU & OpenOCD) test.


## arm-static-lib

Simple static library with and without LTO. 

## arm-f4b-fs-lib

Same as above, but including a static library.


## arm exe spaces

## arm static lib spaces

## arm exe obj spaces

## arm exe lib spaces

- fails on macOS
  

## Debugger diagnosis

### Quick test

If the debug session fails to start, start the GDB client in the Debug folder,
and pass as many commands as needed:

```
.../bin/arm-none-eabi-gdb --nh --nx --ex='set language auto'
```

### Elaborate test

For a more realistic test, first start a GDB server, like QEMU:

```
.../bin/qemu-system-gnuarmeclipse --verbose --board STM32F4-Discovery \
--gdb tcp::1234 -d unimp,guest_errors --nographic \
--semihosting-config enable=on,target=native \
--semihosting-cmdline f4b-fs
```

Then start the GDB client in the Debug folder, and issue MI commands:

```
.../bin/arm-none-eabi-gdb --interpreter=mi2 --nx
```

A typical session looks like:

```
2-gdb-show language
2^done,value="auto"
(gdb) 
3-data-evaluate-expression "sizeof (void*)"
3^done,value="4"
(gdb) 
4-gdb-set language auto
4^done
(gdb) 
5-interpreter-exec console "show endian"
~"The target endianness is set automatically (currently little endian)\n"
5^done
(gdb) 
6-gdb-version
~"GNU gdb (GNU MCU Eclipse Arm Embedded GCC, 64-bit) 8.1.0.20180315-git\n"
~"Copyright (C) 2018 Free Software Foundation, Inc.\n"
~"License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>\nThis is fre\
e software: you are free to change and redistribute it.\nThere is NO WARRANTY, to the extent permitt\
ed by law.  Type \"show copying\"\nand \"show warranty\" for details.\n"
~"This GDB was configured as \"--host=x86_64-apple-darwin14.5.0 --target=arm-none-eabi\".\nT\
ype \"show configuration\" for configuration details."
~"\nFor bug reporting instructions, please see:\n"
~"<http://www.gnu.org/software/gdb/bugs/>.\n"
~"Find the GDB manual and other documentation resources online at:\n<http://www.gnu.org/soft\
ware/gdb/documentation/>.\n"
~"For help, type \"help\".\n"
~"Type \"apropos word\" to search for commands related to \"word\".\n"
6^done
(gdb) 
7-environment-cd /Users/ilg/Desktop/eclipse-workspace-2018-12-gcc-tests/f4b-fs
7^done
(gdb) 
8-gdb-set breakpoint pending on
8^done
(gdb) 
9-enable-pretty-printing
9^done
(gdb) 
10-gdb-set python print-stack none
10^done
(gdb) 
11-gdb-set print object on
11^done
(gdb) 
12-gdb-set print sevenbit-strings on
12^done
(gdb) 
13-gdb-set charset ISO-8859-1
13^error,msg="Cannot convert between character sets `UTF-32' and `ISO-8859-1'"
(gdb) 
14source .gdbinit
&"source .gdbinit\n"
&".gdbinit: No such file or directory.\n"
14^error,msg=".gdbinit: No such file or directory."
(gdb) 
15set mem inaccessible-by-default off
&"set mem inaccessible-by-default off\n"
=cmd-param-changed,param="mem inaccessible-by-default",value="off"
15^done
(gdb) 
16-gdb-set auto-solib-add on
16^done
(gdb) 
17-target-select remote localhost:1234
=thread-group-started,id="i1",pid="42000"
&"warning: No executable has been specified and target does not support\ndetermining executa\
ble automatically.  Try using the \"file\" command."
&"\n"
=thread-created,id="1",group-id="i1"
~"0x00000000 in ?? ()\n"
*stopped,frame={addr="0x00000000",func="??",args=[]},thread-id="1",stopped-threads="all"
17^connected
(gdb) 
18symbol-file /Users/ilg/Desktop/eclipse-workspace-2018-12-gcc-tests/f4b-fs/Debug/f4b-fs.elf\

19load /Users/ilg/Desktop/eclipse-workspace-2018-12-gcc-tests/f4b-fs/Debug/f4b-fs.elf
&"symbol-file /Users/ilg/Desktop/eclipse-workspace-2018-12-gcc-tests/f4b-fs/Debug/f4b-fs.elf\
\n"
~"Reading symbols from /Users/ilg/Desktop/eclipse-workspace-2018-12-gcc-tests/f4b-fs/Debug/f\
4b-fs.elf..."
~"done.\n"
20-list-thread-groups
18^done
(gdb) 
&"load /Users/ilg/Desktop/eclipse-workspace-2018-12-gcc-tests/f4b-fs/Debug/f4b-fs.elf\n"
~"Loading section .isr_vector, size 0x3e8 lma 0x8000000\n"
19+download,{section=".isr_vector",section-size="1000",total-size="933034"}
19+download,{section=".isr_vector",section-sent="1000",section-size="1000",total-sent="1000"\
,total-size="933034"}
~"Loading section .inits, size 0x2c lma 0x80003e8\n"
19+download,{section=".inits",section-size="44",total-size="933034"}
~"Loading section .text, size 0x1e4f lma 0x8000420\n"
19+download,{section=".text",section-size="7759",total-size="933034"}
~"Loading section .data, size 0x78 lma 0x8002270\n"
19+download,{section=".data",section-size="120",total-size="933034"}
~"Start address 0x8000188, load size 8923\n"
~"Transfer rate: 264 KB/sec, 1274 bytes/write.\n"
19^done
(gdb) 
20^done,groups=[{id="i1",type="process",pid="42000"}]
(gdb) 
21-gdb-show --thread-group i1 language
21^done,value="auto"
(gdb) 
22-gdb-set --thread-group i1 language c
23-list-thread-groups i1
22^done
(gdb) 
24-interpreter-exec --thread-group i1 console "p/x (char)-1"
23^done,threads=[{id="1",target-id="Thread 1",details="CPU#0 [running]",frame={level="0",add\
r="0x08000188",func="_start",args=[],file="../system/src/newlib/_startup.c",fullname="/Users/ilg/Des\
ktop/eclipse-workspace-2018-12-gcc-tests/f4b-fs/system/src/newlib/_startup.c",line="246"},state="sto\
pped"}]
(gdb) 
~"$1 = 0xff\n"
24^done
25-stack-info-depth --thread 1 11
(gdb) 
26-data-evaluate-expression --thread-group i1 "sizeof (void*)"
25^done,depth="1"
(gdb) 
26^done,value="4"
(gdb) 
27-gdb-set --thread-group i1 language auto
27^done
(gdb) 
28-interpreter-exec --thread-group i1 console "show endian"
~"The target endianness is set automatically (currently little endian)\n"
28^done
(gdb) 
29-break-insert --thread-group i1 -t -f main
29^done,bkpt={number="1",type="breakpoint",disp="del",enabled="y",addr="0x0800157c",func="ma\
in(int, char**)",file="../src/main.cpp",fullname="/Users/ilg/Desktop/eclipse-workspace-2018-12-gcc-t\
ests/f4b-fs/src/main.cpp",line="155",thread-groups=["i1"],times="0",original-location="main"}
(gdb) 
30monitor system_reset
31tbreak main
32continue
&"monitor system_reset\n"
30^done
(gdb) 
&"tbreak main\n"
33-stack-select-frame --thread 1 0
~"Note: breakpoint 1 also set at pc 0x800157c.\n"
~"Temporary breakpoint 2 at 0x800157c: file ../src/main.cpp, line 155.\n"
=breakpoint-created,bkpt={number="2",type="breakpoint",disp="del",enabled="y",addr="0x080015\
7c",func="main(int, char**)",file="../src/main.cpp",fullname="/Users/ilg/Desktop/eclipse-workspace-2\
018-12-gcc-tests/f4b-fs/src/main.cpp",line="155",thread-groups=["i1"],times="0",original-location="m\
ain"}
31^done
(gdb) 
&"continue\n"
~"Continuing.\n"
32^running
*running,thread-id="all"
(gdb) 
=breakpoint-modified,bkpt={number="1",type="breakpoint",disp="del",enabled="y",addr="0x08001\
57c",func="main(int, char**)",file="../src/main.cpp",fullname="/Users/ilg/Desktop/eclipse-workspace-\
2018-12-gcc-tests/f4b-fs/src/main.cpp",line="155",thread-groups=["i1"],times="1",original-location="\
main"}
=breakpoint-modified,bkpt={number="2",type="breakpoint",disp="del",enabled="y",addr="0x08001\
57c",func="main(int, char**)",file="../src/main.cpp",fullname="/Users/ilg/Desktop/eclipse-workspace-\
2018-12-gcc-tests/f4b-fs/src/main.cpp",line="155",thread-groups=["i1"],times="1",original-location="\
main"}
~"\n"
~"Temporary breakpoint 1, main (argc=1, argv=0x20000004 <argv>) at ../src/main.cpp:155\n"
~"155\t{\n"
*stopped,reason="breakpoint-hit",disp="del",bkptno="1",frame={addr="0x0800157c",func="main",\
args=[{name="argc",value="1"},{name="argv",value="0x20000004 <argv>"}],file="../src/main.cpp",fullna\
me="/Users/ilg/Desktop/eclipse-workspace-2018-12-gcc-tests/f4b-fs/src/main.cpp",line="155"},thread-i\
d="1",stopped-threads="all"
=breakpoint-deleted,id="1"
=breakpoint-deleted,id="2"
(gdb) 
33^done
(gdb) 
34-list-thread-groups
35-thread-info 1
34^done,groups=[{id="i1",type="process",pid="42000"}]
(gdb) 
35^done,threads=[{id="1",target-id="Thread 1",details="CPU#0 [running]",frame={level="0",add\
r="0x0800157c",func="main",args=[{name="argc",value="1"},{name="argv",value="0x20000004 <argv>"}],fi\
le="../src/main.cpp",fullname="/Users/ilg/Desktop/eclipse-workspace-2018-12-gcc-tests/f4b-fs/src/mai\
n.cpp",line="155"},state="stopped"}]
(gdb) 
36-break-delete --thread-group i1 2
~"No breakpoint number 2.\n"
36^done
(gdb) 
37-stack-info-depth --thread 1 11
37^done,depth="1"
(gdb) 
38-stack-select-frame --thread 1 0
38^done
(gdb) 
39-stack-select-frame --thread 1 0
39^done
(gdb) 
40-stack-list-locals --thread 1 --frame 0 1
40^done,locals=[{name="seconds",value="<optimized out>"}]
(gdb) 
41-var-create --thread 1 --frame 0 - * argc
42-var-create --thread 1 --frame 0 - * argv
43-var-create --thread 1 --frame 0 - * seconds
41^done,name="var1",numchild="0",value="1",type="int",thread-id="1",has_more="0"
(gdb) 
42^done,name="var2",numchild="1",value="0x20000004 <argv>",type="char **",thread-id="1",has_\
more="0"
(gdb) 
43^done,name="var3",numchild="0",value="<optimized out>",type="uint32_t",thread-id="1",has_m\
ore="0"
(gdb) 
```
