%include "common.asm"

section .data

    string db "Greetings!"
    string_len equ $-string

section .text

global _start
_start:
    mov rax, SYS_FILE_WRITE
    mov rbx, STDOUT
    mov rcx, string
    mov rdx, string_len
    int LINUX

    mov rax, 1
    mov rbx, 0
    int LINUX
