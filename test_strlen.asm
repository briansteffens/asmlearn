.include "common.asm"

.section .data

STR0:
    .ascii "Greetings!\12\0"

.section .text

.globl _start

_start:
    push $STR0
    call strlen
    addl $4, %esp
    movl $0, %ebx
    movb %al, %bl

    movl $SYS_EXIT, %eax
    int $LINUX
