.include "common.asm"

.section .text

.globl strcpy
.type strcpy, @function

strcpy:
    pushl %ebp
    movl %esp, %ebp

    # Set char index
    movl $0, %ecx

    # Put the input buffer in ebx
    movl 12(%ebp), %ebx

    # Put the output buffer in edx
    movl 8(%ebp), %edx

strcpy_loop_start:
    # Load the next byte from source into al
    movb (%ebx, %ecx, 1), %al

    # Save the byte into the target
    movb %al, (%edx, %ecx, 1)

    # Increment character index
    incl %ecx

    # Check for null char and end copy if so
    cmpb $0, %al
    jne strcpy_loop_start

    # Copy bytes written to eax for return value
    movl %ecx, %eax

    movl %ebp, %esp
    popl %ebp
    ret
