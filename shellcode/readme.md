
sudo apt install gcc-multilib

nasm -f elf[64|32] mycode.nasm
readelf --all mycode.o
ld -o mycode mycode.o [-m elf_i386]
objdump -d mycode

objdump -d shell.o | awk 'f;/_start/ {f=1}' | awk -F '\t' '{print $2}' | awk '{ printf "\\x"$1 "\\x"$2 }'

objdump -d shell | egrep "\s[0-9]" | cut -f 2 | awk '{$1=$1; print}' | sed 's/\s/\\x/g' | awk '{ printf "\\x" $1 }'

gcc [-m32] -z execstack test_shellcode.c -o test_shellcode



# Links

* Introduction to writing shellcode: https://www.vividmachines.com/shellcode/shellcode.html
* Testing shellcode: http://disbauxes.upc.es/code/two-basic-ways-to-run-and-test-shellcode/
* https://shell-storm.org/
