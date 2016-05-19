.include "common.inc"

.section .data

    string: .ascii "Greetings!\12\0"
#    string: .ascii "Farewell!\12\0"

.section .text

.globl _start
.globl strrev

_start:
    push $string                   # String to reverse
    push $9                        # Number of chars to include in the reversal
    call strrev
    addl $8, %esp

    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    movl $string, %ecx
    movl $12, %edx                 # Number of chars to print
    int $LINUX

    movl $0, %ebx
    movl $SYS_EXIT, %eax
    int $LINUX

strrev:
    pushl %ebp
    movl %esp, %ebp

    subl $4, %esp                   # Reserve 4 bytes for max bytesr

    movl 8(%ebp), %eax              # Total count -> eax
    movl $2, %ebx                   # Dividing by 2 -> ebx
    idiv %ebx                       # Total count / 2 -> eax
    decl %eax
    movl %eax, -4(%ebp)             # Store max swaps to perform (-1)

    movl $0, %ecx                   # Start/left counter
    movl 8(%ebp), %edx              # End/right counter (len - 1)
    decl %edx

    movl 12(%ebp), %ebx             # Buffer -> ebx

strrev_loop_start:
    movb (%ebx, %ecx, 1), %al       # Grab char from left
    movb (%ebx, %edx, 1), %ah       # Grab char from right

    movb %ah, (%ebx, %ecx, 1)       # Swap right -> left
    movb %al, (%ebx, %edx, 1)       # Swap left -> right

    cmpl -4(%ebp), %ecx             # Compare left counter to max swaps
    je strrev_loop_end

    incl %ecx                       # Increment left counter
    decl %edx                       # Decrement right counter

    jmp strrev_loop_start

strrev_loop_end:
    movl %ebp, %esp
    popl %ebp
    ret
