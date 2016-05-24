.include "prompt.asm"

.section .bss

    .equ BUFFER_LEN, 5
    .lcomm BUFFER, BUFFER_LEN

.section .data

    PROMPT: .ascii "Enter some text: "
    .equ PROMPT_LEN, 17

    NEWLINE: .ascii "\n"
    .equ NEWLINE_LEN, 1

.section .text

.globl _start
_start:
    movl %esp, %ebp

    pushl $PROMPT
    pushl $PROMPT_LEN
    pushl $BUFFER
    pushl $BUFFER_LEN
    call prompt
    addl $16, %esp

    cmpl $0, %eax
    jl err

# Print result
    movl %eax, %edx
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $BUFFER, %ecx
    int $LINUX

# Print newline
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $NEWLINE, %ecx
    movl $NEWLINE_LEN, %edx
    int $LINUX

    movl $0, %ebx
    jmp exit

err:
    movl %eax, %ebx

exit:
    movl $SYS_EXIT, %eax
    int $LINUX
