.include "common.inc"

.section .bss

    .equ BUFFER_LEN, 255
    .lcomm BUFFER, BUFFER_LEN

    .equ LOCAL_BYTES, 12
    .equ LOCAL_LAST_RET, -4
    .equ LOCAL_INPUT_FILE, -8
    .equ LOCAL_OUTPUT_FILE, -12

.section .data

    input_fn: .ascii "file_input\0"
    output_fn: .ascii "file_output\0"

    ERR_FILE: .ascii "error working with file\0"
    .equ ERR_FILE_LEN, 23

.section .text

.globl _start

_start:
    movl %esp, %ebp
    subl $LOCAL_BYTES, %esp

    # Open input file
    movl $SYS_FILE_OPEN, %eax
    movl $input_fn, %ebx
    movl $SYS_FILE_PERM_READ, %ecx
    movl $0644, %edx
    int $LINUX
    cmpl $0, %eax
    jl error_file
    movl %eax, LOCAL_INPUT_FILE(%ebp)

    # Open output file
    movl $SYS_FILE_OPEN, %eax
    movl $output_fn, %ebx
    movl $SYS_FILE_PERM_WRITE, %ecx
    movl $0644, %edx
    int $LINUX
    cmpl $0, %eax
    jl error_file
    movl %eax, LOCAL_OUTPUT_FILE(%ebp)

read_loop_start:
    # Read from input file
    movl $SYS_FILE_READ, %eax
    movl LOCAL_INPUT_FILE(%ebp), %ebx
    movl $BUFFER, %ecx
    movl $BUFFER_LEN, %edx
    int $LINUX
    cmpl $0, %eax
    jl error_file

    # Write buffer to console
    movl %eax, %edx
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $BUFFER, %ecx
    int $LINUX
    cmpl $0, %eax
    jl error_file
    je end_of_file

    # Write buffer to output file
    movl $SYS_FILE_WRITE, %eax
    movl LOCAL_OUTPUT_FILE(%ebp), %ebx
    movl $BUFFER, %ecx
    int $LINUX

    jmp read_loop_start

end_of_file:

    # Close output file
    movl $SYS_FILE_CLOSE, %eax
    movl LOCAL_OUTPUT_FILE(%ebp), %ebx
    int $LINUX

    # Close input file
    movl $SYS_FILE_CLOSE, %eax
    movl LOCAL_INPUT_FILE(%ebp), %ebx
    int $LINUX

    movl $0, %ebx
    jmp exit_program

error_file:
    movl %eax, LOCAL_LAST_RET(%ebp)
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $ERR_FILE, %ecx
    movl $ERR_FILE_LEN, %edx
    movl LOCAL_LAST_RET(%ebp), %ebx
    int $LINUX

exit_program:
    # Exit program
    movl $SYS_EXIT, %eax
    int $LINUX
