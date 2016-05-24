# Creates the db file if it doesn't exist and resets is (deleting all records)
# if it does.

.include "db.common.asm"

.section .bss
    .equ BUFFER_LEN, 4
    .lcomm BUFFER, BUFFER_LEN

    .equ LOCAL_BYTES, 4
    .equ LOCAL_FILE, -4

.section .text

.globl _start
_start:
    movl %esp, %ebp
    subl $LOCAL_BYTES, %esp

# Open the db file for writing
    movl $SYS_FILE_OPEN, %eax
    movl $FILENAME, %ebx
    movl $SYS_FILE_PERM_WRITE, %ecx
    movl $0644, %edx
    int $LINUX

# Check for error code
    cmpl $0, %eax
    jl err

# Store file pointer
    movl %eax, LOCAL_FILE(%ebp)

# Put the default record count (0) into the buffer for writing
    movl $BUFFER, %eax
    movl $4, %ecx
clear_buffer_loop:
    decl %ecx
    movb $0, (%eax, %ecx, 1)
    cmpl $0, %ecx
    jge clear_buffer_loop

# Write the default record count (0)
    movl $SYS_FILE_WRITE, %eax
    movl LOCAL_FILE(%ebp), %ebx
    movl $BUFFER, %ecx
    movl $BUFFER_LEN, %edx
    int $LINUX

# Check for error code
    cmpl $0, %eax
    jl err

# Close the db file
    movl $SYS_FILE_CLOSE, %eax
    movl LOCAL_FILE(%ebp), %ebx
    int $LINUX

# Check for error code
    cmpl $0, %eax
    jl err

# End program successfully
    jmp exit_success

err:
    movl %eax, %ebx
    jmp exit

exit_success:
    movl $0, %ebx

exit:

# Exit program
    movl $SYS_EXIT, %eax
    int $LINUX
