.section .data

.section .text

.globl _start
.globl factorial

_start:
    push $5
    call factorial
    addl $4, %esp
    movl %eax, %ebx

    movl $1, %eax
    int $0x80

factorial:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %ecx      # Input argument -> ecx
    movl $1, %eax           # 1 -> eax (accumulator)

factorial_loop:
    imull %ecx, %eax

    decl %ecx               # Decrement counter
    cmpl $1, %ecx           # Loop while counter > 1
    jge factorial_loop

    movl %ebp, %esp
    popl %ebp
    ret
