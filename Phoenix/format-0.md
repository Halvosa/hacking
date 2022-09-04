# format-zero

The key to this excercise is the lack of input validation when calling `sprintf`. Looking up the man page for `sprintf`, we find

```
int printf(const char *format, ...);
int sprintf(char *str, const char *format, ...);

...and under the BUGS section...

Code such as printf(foo); often indicates a bug, since foo may contain a % character.  If foo comes from untrusted user input, it may contain  %n, causing the printf() call to write to memory and creating a security hole.
```

It's common for programming languages to provide functionality to apply formats to strings. Maybe you have a float that you wish to output with a specific number of decimals, or maybe you just want to insert some integers into a string without having to do a whole lot of concatenations and type casts.

Format strings are just regular strings, but certain character sequences trigger certain behaviors/commands in the print function. It's perhaps best explained with and example. 

```c
#include <iostream>
using namespace std;

    int main ()
    {
        int foo = 10;
        printf("The variable foo is inserted here %i without explicit concatenation!\n", foo);  
        return 0;
    }
```

```console
Output:
The variable foo is inserted here 10 without explicit concatenation!
```

The `printf` function works like this: The first argument is the format string. It can consist of ordinary characters and so-called conversion specifications mixed in. These begin with the character `%` and ends with a conversion specifier, which is just one of several available characters that trigger certain behavior, i.e., the `i` in the code above. By default, the function looks at the list of arguments following the format string and place them in order into the format string at the location of the conversion specifications, of course formatted acording to the conversion specifier. One can also put flags between the `%` and the specifier to further tweak the format, for example to specify the number of decimals in a formatted float variable.

Remember that arguments are handed to a function by simply placing them in registers and on the stack, followed by the return pointer, before jumping to the function. So `printf` simply "looks" at the argument registers and the stack and grabs as many arguments as there are conversion specifications in the format string. 

Now, what happens if we provide more conversion specifications than the number of arguments following the format string? Well, `printf` will simply continue grabbing whatever it finds in the registers and on the stack! This will cause a memory leak and is exactly what the man page warns us about.

The difference between `printf` and `sprintf` is that `printf` writes to standard output, while `sprintf` places the output in the location pointed to by the first argument.

We set a breakpoint after the `sprintf` function and input a test string of some A's, B's and C's. The buffer is written to by `fgets` and starts at `0x7fffffffe4f0`, and since we did not input any conversion specifications, the string is simply copied to `0x7fffffffe500`, as seen by the repeated pattern.

```console
(gdb) x/32w $rsp
0x7fffffffe4e0:	0xffffe588	0x00007fff	0x00000000	0x00000001
0x7fffffffe4f0:	0x41414141	0x41414141	0x42424242	0x00004343
0x7fffffffe500:	0x41414141	0x41414141	0x42424242	0x00004343
0x7fffffffe510:	0x00000001	0x00000000	0xffffe598	0x00007fff
```

Now, let us see what happens if we input a few `