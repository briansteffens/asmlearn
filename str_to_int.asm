.include "common.asm"

.section .bss

    .equ PARAM_INPUT, 12
    .equ PARAM_INPUT_LEN, 8

    .equ LOCAL_BYTES, 8
    .equ LOCAL_MULTIPLIER, -4
    .equ LOCAL_RET, -8

.section .data

    .equ ASCII_DIGIT_0, 48
    .equ ASCII_DIGIT_9, 57

.section .text

#   Function str_to_int
#       Converts a number in ASCII string format to an integer.
#
#   Stack arguments:
#       INPUT     - The string to parse
#       INPUT_LEN - The number of characters in INPUT to consider part of the
#                   string
#
#   Return values:
#       eax       - 0 if success, otherwise failure
#                   -1 if any chars were not digits
#       ebx       - The parsed integer if successful

.globl str_to_int
.type str_to_int, @function

str_to_int:
    pushl %ebp
    movl %esp, %ebp
    subl $LOCAL_BYTES, %esp

    movl PARAM_INPUT(%ebp), %ebx
    movl PARAM_INPUT_LEN(%ebp), %edx

# Initialize MULTIPLIER
    movl $1, LOCAL_MULTIPLIER(%ebp)

# Initialize RET
    movl $0, LOCAL_RET(%ebp)

str_to_int_loop:

# Decrement character index
    decl %edx

# Load a char from INPUT (in reverse order)
    movl $0, %eax
    movb (%ebx, %edx, 1), %al

# Char must be >= ASCII 0
    cmpb $ASCII_DIGIT_0, %al
    jl str_to_int_err_non_digit

# Char must be <= ASCII 9
    cmpb $ASCII_DIGIT_9, %al
    jg str_to_int_err_non_digit

# Convert ASCII digit to integer
    subl $ASCII_DIGIT_0, %eax

# Scale digit by MULTIPLIER
    movl LOCAL_MULTIPLIER(%ebp), %ecx
    imul %ecx, %eax

# Add scaled digit to RET
    movl LOCAL_RET(%ebp), %ecx
    addl %ecx, %eax
    movl %eax, LOCAL_RET(%ebp)

# Scale up multiplier for next iteration (1 -> 10 -> 100 -> 1000)
    movl LOCAL_MULTIPLIER(%ebp), %eax
    movl $10, %ecx
    imul %ecx, %eax
    movl %eax, LOCAL_MULTIPLIER(%ebp)

# Loop until edx (PARAM_INPUT_LEN) has decremented to zero
    cmpl $0, %edx
    jg str_to_int_loop

# Successful return
    movl $0, %eax
    movl LOCAL_RET(%ebp), %ebx
    jmp str_to_int_ret

str_to_int_err_non_digit:
    movl $-1, %eax

str_to_int_ret:
    movl %ebp, %esp
    popl %ebp
    ret
