.include "common.asm"

.section .data

    haystack: .ascii "Greetings!\12\0"
    needle: .ascii "ing\0"

.section .text

.globl _start

_start:
    push $haystack          # String to search
    push $needle            # String to search for
    call strstr
    addl $8, %esp

    movl %eax, %ebx
    movl $SYS_EXIT, %eax
    int $LINUX
