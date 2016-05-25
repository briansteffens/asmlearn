.include "common.inc"

.section .bss

    .lcomm target, 255

.section .data

    source: .ascii "Greetings!\12\0"

.section .text

.globl _start

_start:
    push $source
    push $target
    call strcpy
    addl $8, %esp

    movl %eax, %edx
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $target, %ecx
    int $LINUX

    movl %edx, %ebx
    movl $SYS_EXIT, %eax
    int $LINUX
