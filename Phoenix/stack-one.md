# stack-one

_The source code for this level can be found here: [stack-one source code](stack-one.c) (https://exploit.education/phoenix/stack-one/)_

This time, our goal is to change the variable locals.changeme to hex value 0x496c5962. 

Let us have a look at the man page for the function strcopy. The description section reads: "_The strcpy() function copies the string pointed to by src, including the terminating null byte ('\0'), to the buffer pointed to by dest.  The strings may not overlap, and the destination string dest must be large enough to receive the copy. Beware of buffer overruns!_" Here, the pointer _dest_ refers to the first parameter and the pointer _src_ refers to the second one. So strcopy copies a string from one place in memory to another. The description warns us of buffer overruns. In the bugs section we find: _If the destination string of a strcpy() is not large enough, then anything might happen.  Overflowing fixed-length string buffers is a favorite cracker technique for taking complete control of the machine.  Any time a program reads or copies data into a buffer, the program first needs to check that there's enough space.  This may be unnecessary if you can show that overflow is impossible, but be careful: programs can get changed over time, in ways that may make the impossible possible._ Like with gets, strcopy by itself does not check whether the destination buffer is large enough to hold the source string that we wish to copy. If it is not, the program will simply continue to write outside the buffer. Since we can freely control the source string via argv, we can easily write whatever we want outside the buffer. 

We expect the changeme variable to be positioned just above the buffer on the stack.
