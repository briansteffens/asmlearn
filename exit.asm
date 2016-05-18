.section .data
.section .text
.globl _start

_start:
    movl $1, %eax       # exit command to Linux
    movl $7, %ebx       # status number argument
    int $0x80
