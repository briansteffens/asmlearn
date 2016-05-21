.include "common.inc"

.section .bss

    .equ BUFFER_LEN, 1048576
    .lcomm BUFFER, BUFFER_LEN

    .equ ARG_INPUT_FILE, 8
    .equ ARG_OUTPUT_FILE, 12

    .equ LOCAL_BYTES, 12
    .equ LOCAL_LAST_RET, -4
    .equ LOCAL_INPUT_FILE, -8
    .equ LOCAL_OUTPUT_FILE, -12

.section .data

    ERR_FILE_INPUT_OPEN: .ascii "Error opening input file for reading\n"
    .equ ERR_FILE_INPUT_OPEN_LEN, 37

    ERR_FILE_OUTPUT_OPEN: .ascii "Error opening output file for writing\n"
    .equ ERR_FILE_OUTPUT_OPEN_LEN, 38

    ERR_FILE_INPUT_READ: .ascii "Error reading from input file\n"
    .equ ERR_FILE_INPUT_READ_LEN, 31

    ERR_FILE_OUTPUT_WRITE: .ascii "Error writing to output file\n"
    .equ ERR_FILE_OUTPUT_WRITE_LEN, 29

.section .text

.globl _start

_start:
    movl %esp, %ebp
    subl $LOCAL_BYTES, %esp

    # Open input file
    movl $SYS_FILE_OPEN, %eax
    movl ARG_INPUT_FILE(%ebp), %ebx
    movl $SYS_FILE_PERM_READ, %ecx
    movl $0644, %edx
    int $LINUX
    cmpl $0, %eax
    jl err_file_input_open
    movl %eax, LOCAL_INPUT_FILE(%ebp)

    # Open output file
    movl $SYS_FILE_OPEN, %eax
    movl ARG_OUTPUT_FILE(%ebp), %ebx
    movl $SYS_FILE_PERM_WRITE, %ecx
    movl $0644, %edx
    int $LINUX
    cmpl $0, %eax
    jl err_file_output_open
    movl %eax, LOCAL_OUTPUT_FILE(%ebp)

read_loop_start:
    # Read from input file
    movl $SYS_FILE_READ, %eax
    movl LOCAL_INPUT_FILE(%ebp), %ebx
    movl $BUFFER, %ecx
    movl $BUFFER_LEN, %edx
    int $LINUX
    cmpl $0, %eax
    je end_of_file
    jl err_file_input_read

    # Write buffer to output file
    movl %eax, %edx
    movl $SYS_FILE_WRITE, %eax
    movl LOCAL_OUTPUT_FILE(%ebp), %ebx
    movl $BUFFER, %ecx
    int $LINUX
    cmpl $0, %eax
    jl err_file_output_write

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
    jmp exit_success

err_file_input_open:
    movl $ERR_FILE_INPUT_OPEN, %ecx
    movl $ERR_FILE_INPUT_OPEN_LEN, %edx
    jmp err_print

err_file_output_open:
    movl $ERR_FILE_OUTPUT_OPEN, %ecx
    movl $ERR_FILE_OUTPUT_OPEN_LEN, %edx
    jmp err_print

err_file_input_read:
    movl $ERR_FILE_INPUT_READ, %ecx
    movl $ERR_FILE_INPUT_READ_LEN, %edx
    jmp err_print

err_file_output_write:
    movl $ERR_FILE_OUTPUT_WRITE, %ecx
    movl $ERR_FILE_OUTPUT_WRITE_LEN, %edx
    jmp err_print

err_print:                                  # Print the string in ecx
    movl %eax, LOCAL_LAST_RET(%ebp)         # Save last error code
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    int $LINUX
    movl LOCAL_LAST_RET(%ebp), %ebx         # Move error code in place for exit
    jmp exit

exit_success:
    movl $0, %ebx                           # Successful status code

exit:
    movl $SYS_EXIT, %eax
    int $LINUX
