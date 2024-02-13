# Reliable-Linux-Shellcode
For some reason common Linux shellcode doesn't include the single instruction it takes to clear room on the stack, often leaving people who don't know how to make shellcode confused when their shellcode doesn't work. Here is a simple x64 and x86 execve shellcode that adds that instruction to make your shellcode consistent and reliable
