* Installation of Ghidra is coded in setup.yml in pc-configs.git
* Installed https://github.com/pudii/gba-ghidra-loader

*https://wrongbaud.github.io/posts/ghidra-debugger/*

```shell
$ gdb-multiarch
(gdb) target remote localhost:2345
(gdb) info registers
r0             0x0                 0
r1             0x4                 4
r2             0x30030f0           50344176
r3             0x1                 1
r4             0x0                 0
r5             0x30030e4           50344164
r6             0x30030e4           50344164
r7             0x30030f0           50344176
r8             0x0                 0
r9             0x0                 0
r10            0x0                 0
r11            0x0                 0
r12            0x2020928           33687848
sp             0x3007e24           0x3007e24
lr             0x80004bf           134218943
pc             0x80008be           0x80008be
cpsr           0x6000003f          1610612799
```
