.include "common.asm"

.section .bss

    .equ PARAM_INPUT, 12
    .equ PARAM_OUTPUT, 8

.section .text

#   Function int_to_str
#       Convert an integer to an ASCII string representation.
#
#   Stack arguments:
#       INPUT     - The integer to convert
#       OUTPUT    - The output buffer. It should have enough space to
#                   accommodate the number of digits in INPUT + 1 for the null
#                   termination character.
#
#   Return values:
#       eax       - 0 if success, otherwise failure
#       ebx       - The number of digits written to OUTPUT (not including null)

.globl int_to_str
.type int_to_str, @function

int_to_str:
    pushl %ebp
    movl %esp, %ebp

# Load input variable
    movl PARAM_INPUT(%ebp), %eax

# Load divisor
    movl $10, %ebx

# Digit counter
    xorl %ecx, %ecx


int_to_str_convert_loop:
    xorl %edx, %edx
    div %ebx

# Convert remainder (digit) to ASCII and push onto the stack
    addl $'0', %edx
    pushl %edx

# Count the new digit
    incl %ecx

    cmpl $0, %eax
    jg int_to_str_convert_loop

# Store digit count for return
    movl %ecx, %ebx


# Load buffer output
    movl PARAM_OUTPUT(%ebp), %edx

int_to_str_reverse_loop:

# Pop ASCII digits off the stack in reverse order and write to output
    popl %eax
    movb %al, (, %edx, 1)

# Move output pointer ahead
    incl %edx

# Decrement counter
    decl %ecx

# Loop while counter > 0
    cmpl $0, %ecx
    jge int_to_str_reverse_loop


# Null-terminate the output
    movb $0, (, %edx, 1)


# Successful return code
    xorl %eax, %eax


    movl %ebp, %esp
    popl %ebp
    ret
