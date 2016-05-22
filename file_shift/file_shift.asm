.include "../common.inc"

.section .bss

    .equ BUFFER_LEN, 255
    .lcomm BUFFER, BUFFER_LEN
    .lcomm BUFFER_BLANK, BUFFER_LEN

    .equ LOCAL_BYTES, 24
    .equ LOCAL_LAST_RET, -4
    .equ LOCAL_FILE, -8
    .equ LOCAL_BYTES_PROCESSED, -12
    .equ LOCAL_BYTES_READ, -16
    .equ LOCAL_CURRENT_BLOCK_SOURCE, -20

    .equ PARAM_FILE, 24
    .equ PARAM_OFFSET, 20
    .equ PARAM_LENGTH, 16
    .equ PARAM_SHIFT, 12
    .equ PARAM_BLANK, 8

.section .data

    ERR_FILE_INPUT_READ: .ascii "Error reading from file\n"
    .equ ERR_FILE_INPUT_READ_LEN, 24

    ERR_FILE_OUTPUT_WRITE: .ascii "Error writing to file\n"
    .equ ERR_FILE_OUTPUT_WRITE_LEN, 22

    ERR_FILE_SEEK: .ascii "Error seeking within file\n"
    .equ ERR_FILE_SEEK_LEN, 26

.section .text

#   Function file_shift
#       Shifts a sequence of bytes in a file forward or back.
#
#   Stack arguments:
#       File handle - must be open for read/write
#       Offset - the start of the sequence to move
#       Length - the number of bytes to include in the move
#       Shift - the number of bytes to shift the sequence
#               (can be negative to shift backwards)
#       Blank - the ASCII ordinal to replace moved blocks with

.globl file_shift
.type file_shift, @function

file_shift:
    pushl %ebp
    movl %esp, %ebp

    movl $0, LOCAL_BYTES_PROCESSED(%ebp)

    # Initialize the blank buffer with the blank byte
    movl PARAM_BLANK(%ebp), %eax
    movl $BUFFER_BLANK, %ebx
    movl $BUFFER_LEN, %ecx
file_shift_blank_buffer_init_start:
    decl %ecx
    movb %al, (%ebx, %ecx, 1)
    cmpl $0, %ecx
    jge file_shift_blank_buffer_init_start

file_shift_loop_start:
    # Seek to start, saving the offset for later
    movl PARAM_OFFSET(%ebp), %ecx
    movl LOCAL_BYTES_PROCESSED(%ebp), %ebx
    addl %ebx, %ecx
    movl %ecx, LOCAL_CURRENT_BLOCK_SOURCE(%ebp)

    movl $SYS_FILE_SEEK, %eax
    movl PARAM_FILE(%ebp), %ebx
    movl $SYS_FILE_SEEK_SET, %edx
    int $LINUX

    # Check for error code
    cmpl $0, %eax
    jl shift_file_err_file_seek

    # Calculate how many bytes are left to process
    movl PARAM_LENGTH(%ebp), %eax
    movl LOCAL_BYTES_PROCESSED(%ebp), %ebx
    subl %ebx, %eax

    # Calculate how many bytes to read in this iteration
    cmpl $BUFFER_LEN, %eax
    jl file_shift_only_read_bytes_left

    # Read a complete buffer size
    movl $BUFFER_LEN, %eax

file_shift_only_read_bytes_left:
    movl %eax, LOCAL_BYTES_READ(%ebp)

    # Read from input file
    movl $SYS_FILE_READ, %eax
    movl PARAM_FILE(%ebp), %ebx
    movl $BUFFER, %ecx
    movl LOCAL_BYTES_READ(%ebp), %edx
    int $LINUX

    # Check for error codes
    cmpl $0, %eax
    jl shift_file_err_file_read

    # Didn't read as many bytes as requested, error
    cmpl LOCAL_BYTES_READ(%ebp), %eax
    jl shift_file_err_file_read

    # Print buffer
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $BUFFER, %ecx
    movl LOCAL_BYTES_READ(%ebp), %edx
    int $LINUX

    # Seek back to source position
    movl $SYS_FILE_SEEK, %eax
    movl PARAM_FILE(%ebp), %ebx
    movl LOCAL_CURRENT_BLOCK_SOURCE(%ebp), %ecx
    movl $SYS_FILE_SEEK_SET, %edx
    int $LINUX

    # Check for error code
    cmpl $0, %eax
    jl shift_file_err_file_seek

    # Blank out source block
    movl $SYS_FILE_WRITE, %eax
    movl PARAM_FILE(%ebp), %ebx
    movl $BUFFER_BLANK, %ecx
    movl LOCAL_BYTES_READ(%ebp), %edx
    int $LINUX

    # Check for error code
    cmpl $0, %eax
    jl shift_file_err_file_write

    # Calculate write position
    movl LOCAL_CURRENT_BLOCK_SOURCE(%ebp), %eax
    movl PARAM_SHIFT(%ebp), %ecx
    addl %eax, %ecx

    # Seek to write position
    movl $SYS_FILE_SEEK, %eax
    movl PARAM_FILE(%ebp), %ebx
    movl $SYS_FILE_SEEK_SET, %edx
    int $LINUX

    # Check for error code
    cmpl $0, %eax
    jl shift_file_err_file_seek

    # Write buffer to new position
    movl $SYS_FILE_WRITE, %eax
    movl PARAM_FILE(%ebp), %ebx
    movl $BUFFER, %ecx
    movl LOCAL_BYTES_READ(%ebp), %edx
    int $LINUX

    # Check for error code
    cmpl $0, %eax
    jl shift_file_err_file_write

    # Add bytes processed to running total
    movl LOCAL_BYTES_PROCESSED(%ebp), %eax
    movl LOCAL_BYTES_READ(%ebp), %ebx
    addl %ebx, %eax
    movl %eax, LOCAL_BYTES_PROCESSED(%ebp)

    # Loop until we've processed the total number of bytes requested
    movl PARAM_LENGTH(%ebp), %ebx
    cmpl %ebx, %eax
    jl file_shift_loop_start

    movl $0, %ebx
    jmp shift_file_ret_success

shift_file_err_file_read:
    movl $ERR_FILE_INPUT_READ, %ecx
    movl $ERR_FILE_INPUT_READ_LEN, %edx
    jmp shift_file_err_print

shift_file_err_file_seek:
    movl $ERR_FILE_SEEK, %ecx
    movl $ERR_FILE_SEEK_LEN, %edx
    jmp shift_file_err_print

shift_file_err_file_write:
    movl $ERR_FILE_OUTPUT_WRITE, %ecx
    movl $ERR_FILE_OUTPUT_WRITE_LEN, %edx
    jmp err_print

shift_file_err_print:                       # Print the string in ecx
    movl %eax, LOCAL_LAST_RET(%ebp)         # Save last error code
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    int $LINUX
    movl LOCAL_LAST_RET(%ebp), %ebx         # Move error code in place for exit
    jmp shift_file_ret

shift_file_ret_success:
    movl $0, %eax                           # Successful status code

shift_file_ret:
    movl %ebp, %esp
    popl %ebp
    ret
