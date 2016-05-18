.section .data

.section .text

.globl _start
.globl square

_start:
    push $5
    call square
    addl $4, %esp
    movl %eax, %ebx     # square() return -> os exit code

    movl $1, %eax
    int $0x80

square:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax      # Input argument -> eax
    movl %eax, %ebx         # Input argument -> ebx
    imull %ebx, %eax        # Input arg * input arg

    movl %ebp, %esp
    popl %ebp
    ret
