.include "common.inc"

.section .bss

    string: .long 0

.section .text

.globl _start
_start:
    movl %esp, %ebp

# Init memory manager
    call allocate_init

# Allocate a string
    pushl $255
    call allocate
    addl $4, %esp
    cmpl $0, %eax
    je err
    movl %eax, string

# Write some text to the string
    movl string, %ebx
    movl $0, %ecx
    movb $72, (%ebx, %ecx, 1)
    incl %ecx
    movb $105, (%ebx, %ecx, 1)
    incl %ecx
    movb $ASCII_LF, (%ebx, %ecx, 1)
    incl %ecx
    movb $0, (%ebx, %ecx, 1)

# Write string to stdout
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl string, %ecx
    movl $3, %edx
    int $LINUX
    cmpl $0, %eax
    jl err

# Free the string
    pushl string
    call deallocate
    addl $4, %esp

    movl $0, %ebx
    jmp exit

err:
    movl %eax, %ebx

exit:
    movl $SYS_EXIT, %eax
    int $LINUX
