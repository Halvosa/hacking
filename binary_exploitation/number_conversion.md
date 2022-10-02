
## Representations of integer literals
```python
# from decimal to binary and hex representations
>>> bin(16)
'0b10000'
>>> hex(16)
'0x10'

# and then back to decimal
>>> int(0b10000)
16
>>> int(0x10)
16

# lastly, between hex and binary
>>> hex(0b10000)
'0x10'
>>> bin(0x10)
'0b10000'
```

## Character String Representations
To convert a string of characters into its hex values:

```python
>>> "ABCD".encode().hex()
'41424344'
```

## Character String to Hex
```python
>>> import struct
>>> hex(struct.unpack("I", b"ABCD")[0])
'0x44434241'

# and big-endian
>>> hex(struct.unpack(">I", b"ABCD")[0])
'0x44434241'
```

To convert back:
```python
>>> struct.pack("I", 0x44434241)
b'ABCD'
>>> struct.pack("I", 0x41599990)
b'\x90\x99YA'
>>> struct.pack(">I", 0x41599990)
b'AY\x99\x90'
```

`I` is only 4 bytes, so for large 64-bit 8 byte integers, use `Q` instead:
```python
>>> struct.pack("Q", 0x3044344546464646)
b'FFFFE4D0'
```

## Program Input
If you want to input raw bytes into a string, for example to place specific hex values in memory:
```python
>>> print("\x41\x42\x01\x27\x29")
AB')
```

```console
$ ./somebinary < python -c 'print("A"*32 + "\x12\x43\x21")'
```

## Python Code as Input to GDB "run"
```sh
(gdb) r <<< $(python3 -c 'print("hello")')
```

## Print address of symbol
```
(gdb) info address <symbol>
(gdb) p &<symbol>
```

