.include "common.inc"

.section .bss

    .equ LOCAL_BYTES, 40
#    .equ LOCAL_LAST_RET, -4

    .equ PARAM_PROMPT, 20
    .equ PARAM_PROMPT_LEN, 16
    .equ PARAM_BUFFER, 12
    .equ PARAM_BUFFER_LEN, 8

.section .data

    ERR_FILE_INPUT_READ: .ascii "Error reading from file\n"
    .equ ERR_FILE_INPUT_READ_LEN, 24

    ERR_FILE_OUTPUT_WRITE: .ascii "Error writing to file\n"
    .equ ERR_FILE_OUTPUT_WRITE_LEN, 22

    ERR_FILE_SEEK: .ascii "Error seeking within file\n"
    .equ ERR_FILE_SEEK_LEN, 26

.section .text

#   Function prompt
#       Accepts input from STDIN with bounds-checking and a prompt on STDOUT.
#
#   Stack arguments:
#       PROMPT     - The text to print on STDOUT to prompt the user
#       PROMPT_LEN - The number of chars to print from PROMPT
#       BUFFER     - The buffer to write user input to. Must have at least one
#                    more byte available than indicated by BUFFER_LEN to
#                    accommodate newline from STDIN.
#       BUFFER_LEN - The max number of chars to accept from STDIN.
#
#   Return values:
#       eax        - If non-negative, the number of characters read into BUFFER
#                    If -1, the user entered too many characters
#                    If < -1, unknown (probably IO related) error

.globl prompt
.type prompt, @function

prompt:
    pushl %ebp
    movl %esp, %ebp
    subl $LOCAL_BYTES, %esp

# Write prompt text
    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl PARAM_PROMPT(%ebp), %ecx
    movl PARAM_PROMPT_LEN(%ebp), %edx
    int $LINUX

# Error check
    cmpl $0, %eax
    jl prompt_ret

# Read from STDIN
    movl $SYS_FILE_READ, %eax
    movl $STDIN, %ebx
    movl PARAM_BUFFER(%ebp), %ecx
    movl PARAM_BUFFER_LEN(%ebp), %edx
    incl %edx
    int $LINUX

# Check for error code
    cmpl $0, %eax
    jl prompt_ret

# Check last character read. Should be a newline, otherwise user entered
# too many characters.
    decl %eax
    movl PARAM_BUFFER(%ebp), %ebx
    movl $0, %edx
    movb (%ebx, %eax, 1), %dl
    cmpb $ASCII_LF, %dl
    jne prompt_err_out_of_bounds

# Blank newline
    movb $0, (%ebx, %eax, 1)

# Undo decrement
    incl %eax

    jmp prompt_ret

prompt_err_out_of_bounds:
    movl $-1, %eax

prompt_ret:
    movl %ebp, %esp
    popl %ebp
    ret
