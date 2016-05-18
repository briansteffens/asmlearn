.section .data

.section .text

.globl _start
_start:
    push $3          # Calculate 2^3
    push $2
    call power
    addl $8, %esp    # Reset the stack pointer
    pushl %eax       # Save the result of the call

    pushl $2         # Calculate 5^2
    pushl $5
    call power
    addl $8, %esp

    popl %ebx        # Result of second call is in eax, put first call result
                     # in ebx

    addl %eax, %ebx  # Sum the two function results

    movl $1, %eax    # Exit, returning %ebx to the OS
    int $0x80

.type power, @function
power:
    pushl %ebp             # Save base pointer
    movl %esp, %ebp        # Make stack pointer the base pointer
    subl $4, %esp          # Reserve 4 bytes for local variable storage

    movl 8(%ebp), %ebx     # First function argument -> ebx
    movl 12(%ebp), %ecx    # Second function argument -> ecx

    movl %ebx, -4(%ebp)    # Store current result

power_loop_start:
    cmpl $1, %ecx          # End loop if power is 1
    je end_power

    movl -4(%ebp), %eax    # Move current result into eax
    imull %ebx, %eax       # Multiply current result by base number
    movl %eax, -4(%ebp)    # Save changed current result

    decl %ecx              # Decrease power since it's been applied
    jmp power_loop_start   # Continue loop

end_power:
    movl -4(%ebp), %eax    # Place return value in eax
    movl %ebp, %esp        # Restore stack pointer
    popl %ebp              # Restore base pointer
    ret
