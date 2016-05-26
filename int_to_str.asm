.include "common.inc"

.section .bss

    .equ PARAM_INPUT, 12
    .equ PARAM_OUTPUT, 8

    .equ LOCAL_BYTES, 16
    .equ LOCAL_DIGITS, -4
    .equ LOCAL_MULTIPLIER, -8
    .equ LOCAL_REDUCER, -12
    .equ LOCAL_DIGIT, -16

    .equ MAX_DIGITS, 10

.section .data

    .equ ASCII_DIGIT_0, 48
    .equ ASCII_DIGIT_9, 57

.section .text

#   Function int_to_str
#       Convert an integer to an ASCII string representation.
#
#   Stack arguments:
#       INPUT     - The integer to convert
#       OUTPUT    - The output buffer. It should have 11 characters to support
#                   any value of INPUT (10 digits + null character)
#
#   Return values:
#       eax       - 0 if success, otherwise failure
#       ebx       - The number of characters written to OUTPUT
#
#   The following pseudo-code shows the rough logic behind this (each loop
#   iteration grabs one digit from INPUT):
#
#       MULTIPLIER = 10
#       REDUCER = 1
#       while (INPUT != 0) {
#           REMAINDER = INPUT % MULTIPLIER
#           INPUT -= REMAINDER
#           DIGIT = REMAINDER / REDUCER
#           MULTIPLIER *= 10
#           REDUCER *= 10
#       }
#
#   The digits are discovered in reverse order and written to the end of the
#   buffer output since we don't know how many digits there will be ahead of
#   time. Once finished, digits are shifted to the beginning of the string.
#   I don't love that from a performance perspective but pre-calculating the
#   number of digits seemed worse (an extra loop of division operations).
#   Optionally a hard-coded series of comparisons against 10, 100, 1000, etc
#   may be faster but fairly ugly.

.globl int_to_str
.type int_to_str, @function

int_to_str:
    pushl %ebp
    movl %esp, %ebp
    subl $LOCAL_BYTES, %esp


# Start with the last digit index
    movl $MAX_DIGITS, %eax
    decl %eax
    movl %eax, LOCAL_DIGIT(%ebp)

# Initialize variables
    movl $10, LOCAL_MULTIPLIER(%ebp)
    movl $1, LOCAL_REDUCER(%ebp)

int_to_str_process:

# Calculate remainder
    movl PARAM_INPUT(%ebp), %eax
    xor %edx, %edx
    movl LOCAL_MULTIPLIER(%ebp), %ebx
    div %ebx

# Remove remainder from input
    movl PARAM_INPUT(%ebp), %eax
    subl %edx, %eax
    movl %eax, PARAM_INPUT(%ebp)

# Get digit
    movl %edx, %eax
    xor %edx, %edx
    movl LOCAL_REDUCER(%ebp), %ebx
    div %ebx

# Convert digit to ASCII
    movl $ASCII_DIGIT_0, %ebx
    addl %ebx, %eax

# Save digit to output buffer
    movl PARAM_OUTPUT(%ebp), %ebx
    movl LOCAL_DIGIT(%ebp), %ecx
    movb %al, (%ebx, %ecx, 1)


# Decrement digit index
    movl LOCAL_DIGIT(%ebp), %eax
    decl %eax
    movl %eax, LOCAL_DIGIT(%ebp)

# Scale up multiplier (10->100->1000)
    movl LOCAL_MULTIPLIER(%ebp), %ebx
    movl $10, %ecx
    imul %ecx, %ebx
    movl %ebx, LOCAL_MULTIPLIER(%ebp)

# Scale up reducer (1->10->100)
    movl LOCAL_REDUCER(%ebp), %ebx
    imul %ecx, %ebx
    movl %ebx, LOCAL_REDUCER(%ebp)

# Loop while INPUT > 0
    movl PARAM_INPUT(%ebp), %eax
    cmpl $0, %eax
    jg int_to_str_process


# Calculate digit count
    movl LOCAL_DIGIT(%ebp), %eax
    incl %eax
    movl %eax, LOCAL_DIGIT(%ebp)
    movl $MAX_DIGITS, %ebx
    subl %eax, %ebx
    movl %ebx, LOCAL_DIGITS(%ebp)

# Shift digits from end of string to beginning of string
    movl PARAM_OUTPUT(%ebp), %eax       # Source in output
    movl LOCAL_DIGIT(%ebp), %ecx
    addl %ecx, %eax

    movl PARAM_OUTPUT(%ebp), %ebx       # Destination in output

    movl $0, %ecx                       # Digit index

int_to_str_shift:
    movb (%eax, %ecx, 1), %dl
    movb %dl, (%ebx, %ecx, 1)

    incl %ecx

# Loop while digit index < DIGITS
    movl LOCAL_DIGITS(%ebp), %edx
    cmpl %edx, %ecx
    jl int_to_str_shift


# Null out the rest of the output
    movl MAX_DIGITS(%ebp), %edx

int_to_str_null:
    movb $0, (%ebx, %ecx, 1)

    incl %ecx

# Loop while digit index < MAX_DIGITS
    cmpl %edx, %ecx
    jl int_to_str_null


# Successful return
    movl LOCAL_DIGITS(%ebp), %ebx
    movl $0, %eax

int_to_str_ret:
    movl %ebp, %esp
    popl %ebp
    ret
