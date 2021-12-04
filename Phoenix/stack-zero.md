The source code for this level can be found here: [stack-zero source code](stack-zero.c) (https://exploit.education/phoenix/stack-zero/)

Let us have a look at the man page for the gets function. Under the "Bugs"-section it says: _Never use gets(). Because it is impossible to tell without knowing the data in advance how many characters gets() will read, and because gets() will continue to store characters past the end of the buffer, it is extremely dangerous to use. It has been used to break computer security. Use fgets() instead._ Thus, even though the buffer is only 64 bytes in size, gets does not do any checks to see if we write more bytes than that. The changeme variable should be stored right above the buffer on the stack, so to change the variable, all we have to do is to write a bit outside the buffer. Let us try to feed 65 bytes to the buffer.

``console
user@phoenix-amd64:/opt/phoenix/amd64$ python -c 'print("A"*65)' | ./stack-zero 
Welcome to phoenix/stack-zero, brought to you by https://exploit.education
Well done, the 'changeme' variable has been changed!
``
