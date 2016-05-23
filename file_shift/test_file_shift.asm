.include "file_shift.asm"

.section .bss

    .equ LOCAL_BYTES, 4
    .equ LOCAL_FILE, -4

.section .data

    filename: .ascii "test_file_shift.txt\0"

    ERR_FILE_INPUT_OPEN: .ascii "Error opening file for reading and writing\n"
    .equ ERR_FILE_INPUT_OPEN_LEN, 43

.section .text

.globl _start

_start:
    movl %esp, %ebp
    subl $LOCAL_BYTES, %esp

    # Open file
    movl $SYS_FILE_OPEN, %eax
    movl $filename, %ebx
    movl $SYS_FILE_PERM_READWRITE, %ecx
    movl $0644, %edx
    int $LINUX
    cmpl $0, %eax
    jl err_file_input_open
    movl %eax, LOCAL_FILE(%ebp)

    # Call file shift
    pushl LOCAL_FILE(%ebp)
    pushl $12
    pushl $5
    pushl $3
    pushl $32                   # Space
    call file_shift
    addl $16, %esp

    # Close file
    movl $SYS_FILE_CLOSE, %eax
    movl LOCAL_FILE(%ebp), %ebx
    int $LINUX

    jmp exit_success

err_file_input_open:
    movl $ERR_FILE_INPUT_OPEN, %ecx
    movl $ERR_FILE_INPUT_OPEN_LEN, %edx
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

    movl %eax, %ebx
    movl $SYS_EXIT, %eax
    int $LINUX
