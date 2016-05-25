.include "str_to_int.asm"

.section .data

    INPUT: .ascii "123"
    .equ INPUT_LEN, 3

.section .text

.globl _start
_start:
    movl %esp, %ebp

    pushl $INPUT
    pushl $INPUT_LEN
    call str_to_int
    addl $8, %esp

    cmpl $0, %eax
    jne err

    jmp exit

err:
    movl %eax, %ebx

exit:
    movl $SYS_EXIT, %eax
    int $LINUX
