#include <stdio.h>

int main()
{
    char buffer[16];
    fgets(buffer, sizeof(buffer) - 1, stdin);
    printf(buffer);
}