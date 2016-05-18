.include "common.inc"

.section .data

STR0:
    .ascii "Greetings!\12\0"

.section .text

.globl _start
.globl strlen

_start:
    push $STR0
    call strlen
    addl $4, %esp
    movl $0, %ebx
    movb %al, %bl

    movl $SYS_EXIT, %eax
    int $LINUX

strlen:
    pushl %ebp
    movl %esp, %ebp

    movl $-1, %ecx
    movl 8(%ebp), %ebx

strlen_loop_start:
    incl %ecx
    movb (%ebx, %ecx, 1), %al
    cmpb $0, %al
    jne strlen_loop_start

    movl %ecx, %eax

    movl %ebp, %esp
    popl %ebp
    ret
