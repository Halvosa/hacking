GBA key input register is 0x04000130. We can make GDB break at any key input by setting up a watchpoint:
```shell
(gdb) rwatch *0x04000130
Hardware read watchpoint 1: *0x04000130
(gdb) c
Continuing.
```
However, we notice that Pokemon Fire Red breaks immediately, and GDB outputs:
```shell
Hardware read watchpoint 1: *0x04000130

Value = 1023
```
The value of the key input register is 1023 in decimal, which in binary is:
```
(gdb) p/t 1023
$2 = 1111111111
```
We know that bit state 1 means "not pressed" and 0 means pressed, so no keys are currently pressed and GDB breaks anyways. That has to mean that Pokemon Fire Red is polling for input every frame. We could add a condition to the breakpoint like so:

```shell
(gdb) condition 1 *0x04000130 != 0x3ff
```

But a simpler strategy is to break whenever the register is written to, by using the watch command instead or rwatch:

```shell
(gdb) watch *0x04000130
Hardware watchpoint 2: *0x04000130
(gdb) c
Continuing.
```

If we go back to the emulator and press any key, GDB will break:

```shell
Hardware watchpoint 2: *0x04000130

Old value = 1023
New value = 1021

(gdb) p/t 1021
$5 = 1111111101
```

Bit number 1 (starting at 0, i.e the 2nd bit) is 0, which we know to be the B-button55.


