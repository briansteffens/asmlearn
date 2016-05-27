.include "common.inc"

.section .data

    STR: .ascii "Greetings!\12\0"
    .equ STR_LEN, 11

.section .text

.globl _start

_start:
    push $STR
    push $STR_LEN
    call strdebug
    addl $8, %esp
    movl $0, %ebx

    movl $SYS_EXIT, %eax
    int $LINUX
