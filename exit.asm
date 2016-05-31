section .text

global _start
_start:
    mov rax, 1      ; exit command to Linux
    mov rbx, 7      ; exit status code
    int 0x80
