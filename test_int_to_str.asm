.include "common.inc"

.section .bss

    .equ BUFFER_LEN, 16
    .lcomm BUFFER, BUFFER_LEN

.section .text

.globl _start
_start:
    movl %esp, %ebp

    pushl $33278
    pushl $BUFFER
    call int_to_str
    addl $8, %esp

    cmpl $0, %eax
    jne err
aaa:
    movl %ebx, %edx
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $BUFFER, %ecx
    int $LINUX
    cmpl $0, %eax
    jl err

    jmp exit

err:
    movl %eax, %ebx

exit:
    movl $SYS_EXIT, %eax
    int $LINUX
