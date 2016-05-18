.section .data

.section .text

.globl _start
.globl factorial

_start:
    push $5
    call factorial
    addl $4, %esp
    movl %eax, %ebx     # factorial() return -> os exit code

    movl $1, %eax
    int $0x80

factorial:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax      # Input argument -> eax

    cmpl $1, %eax           # If input is down to 1, return 1 (base case)
    je factorial_return

    decl %eax               # Decrement input argument

    push %eax               # Make recursive call with decremented input arg
    call factorial
    addl $4, %esp

    movl 8(%ebp), %ebx      # Input arg -> ebx
    imull %ebx, %eax        # Input arg * recursive result

factorial_return:
    movl %ebp, %esp
    popl %ebp
    ret
