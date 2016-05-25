# Creates the db file if it doesn't exist and resets is (deleting all records)
# if it does.

.include "db.common.asm"
.include "../prompt.asm"

.section .bss
    .equ BUFFER_LEN, 10
    .lcomm BUFFER, BUFFER_LEN + 1

    .lcomm FIRST_NAME, RECORD_FIRST_NAME_LEN + 1
    .lcomm LAST_NAME, RECORD_LAST_NAME_LEN + 1

    .equ LOCAL_BYTES, 16
    .equ LOCAL_FILE, -4
    .equ LOCAL_BYTES_READ, -8
    .equ LOCAL_AGE, -12
    .equ LOCAL_RECORD_COUNT, -16

.section .data

    PROMPT_FIRST_NAME: .ascii "Enter first name: "
    .equ PROMPT_FIRST_NAME_LEN, 18

    PROMPT_LAST_NAME: .ascii "Enter last name: "
    .equ PROMPT_LAST_NAME_LEN, 17

    PROMPT_AGE: .ascii "Enter age: "
    .equ PROMPT_AGE_LEN, 11

    ERR_OUT_OF_BOUNDS: .ascii "Input exceeds maximum characters allowed\n"
    .equ ERR_OUT_OF_BOUNDS_LEN, 41

    ERR_INT_PARSE: .ascii "Error parsing int\n"
    .equ ERR_INT_PARSE_LEN, 18

.section .text

.globl _start
_start:
    movl %esp, %ebp
    subl $LOCAL_BYTES, %esp

# Prompt for first name
    pushl $PROMPT_FIRST_NAME
    pushl $PROMPT_FIRST_NAME_LEN
    pushl $FIRST_NAME
    pushl $RECORD_FIRST_NAME_LEN
    call prompt

# Error check
    cmpl $-1, %eax
    je err_out_of_bounds
    jl err

# Prompt for last name
    pushl $PROMPT_LAST_NAME
    pushl $PROMPT_LAST_NAME_LEN
    pushl $LAST_NAME
    pushl $RECORD_LAST_NAME_LEN
    call prompt

# Error check
    cmpl $0, %eax
    je err_out_of_bounds
    jl err

# Prompt for age
    pushl $PROMPT_AGE
    pushl $PROMPT_AGE_LEN
    pushl $BUFFER
    pushl $BUFFER_LEN
    call prompt

# Error check
    cmpl $0, %eax
    je err_out_of_bounds
    jl err

# Convert age string to int
    pushl $BUFFER
    pushl %eax
    call str_to_int
    addl $8, %esp

# Error check
    cmpl $0, %eax
    jne err_int_parse

# Save age to local
    movl %ebx, LOCAL_AGE(%ebp)

# Open the db file for reading/writing
    movl $SYS_FILE_OPEN, %eax
    movl $FILENAME, %ebx
    movl $SYS_FILE_PERM_READWRITE, %ecx
    movl $0644, %edx
    int $LINUX

# Check for error code
    cmpl $0, %eax
    jl err

# Store file pointer
    movl %eax, LOCAL_FILE(%ebp)

# Read record count
    movl $SYS_FILE_READ, %eax
    movl LOCAL_FILE(%ebp), %ebx
    leal LOCAL_RECORD_COUNT(%ebp), %ecx
    movl $4, %edx
    int $LINUX

# Check for error
    cmpl $0, %eax
    jl err

# Increment record count since we're adding a record
    movl LOCAL_RECORD_COUNT(%ebp), %eax
    incl %eax
    movl %eax, LOCAL_RECORD_COUNT(%ebp)

# Seek to beginning of file to rewrite new record count
    movl $SYS_FILE_SEEK, %eax
    movl LOCAL_FILE(%ebp), %ebx
    movl $0, %ecx
    movl $SYS_FILE_SEEK_SET, %edx
    int $LINUX

# Error check
    cmpl $0, %eax
    jl err

# Write the new record count to the file
    movl $SYS_FILE_WRITE, %eax
    movl LOCAL_FILE(%ebp), %ebx
    leal LOCAL_RECORD_COUNT(%ebp), %ecx
    movl $4, %edx
    int $LINUX

# Error check
    cmpl $0, %eax
    jl err

# Seek to end of file
    movl $SYS_FILE_SEEK, %eax
    movl LOCAL_FILE(%ebp), %ebx
    movl $0, %ecx
    movl $SYS_FILE_SEEK_END, %edx
    int $LINUX

# Error check
    cmpl $0, %eax
    jl err

# Write first name to file
    movl $SYS_FILE_WRITE, %eax
    movl LOCAL_FILE(%ebp), %ebx
    movl $FIRST_NAME, %ecx
    movl $RECORD_FIRST_NAME_LEN, %edx
    int $LINUX

# Error check
    cmpl $0, %eax
    jl err

# Write last name to file
    movl $SYS_FILE_WRITE, %eax
    movl LOCAL_FILE(%ebp), %ebx
    movl $LAST_NAME, %ecx
    movl $RECORD_LAST_NAME_LEN, %edx
    int $LINUX

# Error check
    cmpl $0, %eax
    jl err

# Write AGE to file
    movl $SYS_FILE_WRITE, %eax
    movl LOCAL_FILE(%ebp), %ebx
    leal LOCAL_AGE(%ebp), %ecx
    movl $4, %edx
    int $LINUX

# Error check
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

err_out_of_bounds:
    movl $ERR_OUT_OF_BOUNDS, %ecx
    movl $ERR_OUT_OF_BOUNDS_LEN, %edx
    jmp err_print

err_int_parse:
    movl $ERR_INT_PARSE, %ecx
    movl $ERR_INT_PARSE_LEN, %edx
    jmp err_print

err_print:

# Print error message in ecx + edx
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    int $LINUX

# Check for error code
    cmpl $0, %eax
    jl err

    jmp exit

err:
    movl %eax, %ebx
    jmp exit

exit_success:
    movl $0, %ebx

exit:

# Exit program
    movl $SYS_EXIT, %eax
    int $LINUX
