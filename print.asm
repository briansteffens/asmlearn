.include "common.inc"

.section .data

STR0:
    .ascii "Greetings!\12\0"

.section .text

.globl _start

_start:
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $STR0, %ecx
    movl $11, %edx
    int $LINUX

    movl $SYS_EXIT, %eax
    movl $SYS_EXIT_SUCCESS, %ebx
    int $LINUX
