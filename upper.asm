.include "common.asm"

.section .bss

    .equ BUFFER_LEN, 8192
    .lcomm BUFFER, BUFFER_LEN

    .equ ASCII_LOWER_START, 97
    .equ ASCII_LOWER_END, 122

    .equ ASCII_UPPER_CONVERSION, 32

.section .data

    ERR_FILE_INPUT_READ: .ascii "Error reading from stdin\n"
    .equ ERR_FILE_INPUT_READ_LEN, 25

    ERR_FILE_OUTPUT_WRITE: .ascii "Error writing to stdout\n"
    .equ ERR_FILE_OUTPUT_WRITE_LEN, 24

.section .text

.globl _start

_start:
    movl %esp, %ebp

read_loop_start:
    # Read from stdin
    movl $SYS_FILE_READ, %eax
    movl $STDIN, %ebx
    movl $BUFFER, %ecx
    movl $BUFFER_LEN, %edx
    int $LINUX
    cmpl $0, %eax
    je end_of_file

    movl $-1, %ecx
    movl $BUFFER, %edx

to_upper_loop_start:
    incl %ecx

    cmpl %ecx, %ebx
    jl buffer_processing_done

    movb (%edx, %ecx, 1), %bl           # load byte from buffer

    cmpb $ASCII_LOWER_START, %bl
    jl to_upper_loop_start              # char < ascii lower set -> continue

    cmpb $ASCII_LOWER_END, %bl
    jg to_upper_loop_start              # char > ascii lower set -> continue

    subb $ASCII_UPPER_CONVERSION, %bl   # convert to upper case

    movb %bl, (%edx, %ecx, 1)           # save byte back to buffer
    jmp to_upper_loop_start

buffer_processing_done:
    # Write to stdout
    movl %eax, %edx
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $BUFFER, %ecx
    int $LINUX

    jmp read_loop_start

end_of_file:
    movl $0, %ebx
    movl $SYS_EXIT, %eax
    int $LINUX
