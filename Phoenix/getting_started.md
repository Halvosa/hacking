# Getting Started

First, go to https://exploit.education/downloads/ and download the AMD64 Qcow2 image. Next, extract all the files from the tar archive.

```console
halvor@halvor-MACH-WX9:~/Downloads$ tar -xvf exploit-education-phoenix-amd64-v1.0.0-alpha-3.tar.xz 
halvor@halvor-MACH-WX9:~/Downloads$ chmod u+x exploit-education-phoenix-amd64/boot-exploit-education-phoenix-amd64.sh 
halvor@halvor-MACH-WX9:~/Downloads$ cd exploit-education-phoenix-amd64/
halvor@halvor-MACH-WX9:~/Downloads/exploit-education-phoenix-amd64$ ./boot-exploit-education-phoenix-amd64.sh
```

The VM should now be running and you should have a console display. We can log in with the account "user" and password "user", as mentioned on https://exploit.education. To SSH into the VM, we must connect to 127.0.0.1 (localhost) on port 2222, as seen from the boot script:

```console
halvor@halvor-MACH-WX9:~$ cat Downloads/exploit-education-phoenix-amd64/boot-exploit-education-phoenix-amd64.sh 
#!/bin/sh

exec qemu-system-x86_64 \
  -kernel vmlinuz-4.9.0-8-amd64 \
  -initrd initrd.img-4.9.0-8-amd64 \
  -append "root=/dev/vda1" \
  -m 1024M \
  -netdev user,id=unet,**hostfwd=tcp:127.0.0.1:2222-:22** \
  -device virtio-net,netdev=unet \
  -drive file=exploit-education-phoenix-amd64.qcow2,if=virtio,format=qcow2,index=0 

halvor@halvor-MACH-WX9:~$ ssh -p 2222 user@localhost
...output omitted...
Last login: Sat Dec  4 15:53:45 2021
user@phoenix-amd64:~$ 
```

Each level/excercise is a binary that we need to exploit. All of them should be executable and have the setuid bit set. Let us use find to find them.

```console
user@phoenix-amd64:~$ find / -perm -4111 2> /dev/null
...output omitted...
/opt/phoenix/amd64/stack-four
/opt/phoenix/amd64/heap-two
/opt/phoenix/amd64/stack-five
/opt/phoenix/amd64/format-one
/opt/phoenix/amd64/format-two
/opt/phoenix/amd64/format-three
/opt/phoenix/amd64/format-zero
/opt/phoenix/amd64/stack-one
/opt/phoenix/amd64/heap-one
/opt/phoenix/amd64/stack-zero
/opt/phoenix/amd64/format-four
/opt/phoenix/amd64/heap-three
/opt/phoenix/amd64/stack-two
/opt/phoenix/amd64/stack-six
/opt/phoenix/amd64/heap-zero
/opt/phoenix/amd64/stack-three
...output omitted...
user@phoenix-amd64:~$ cd /opt/phoenix/amd64/
```
