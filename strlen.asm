.include "common.inc"

.section .text

.globl strlen
.type strlen, @function

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
