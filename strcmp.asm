.include "common.inc"

.section .data

STR0:
    .ascii "Greetings!\12\0"
STR1:
    .ascii "Greetings!\12\0"

.section .text

.globl _start
.globl strcmp

_start:
    pushl $STR0
    pushl $STR1
    call strcmp
    addl $8, %esp
    movl %eax, %ebx

    movl $SYS_EXIT, %eax
    int $LINUX

strcmp:
    pushl %ebp
    movl %esp, %ebp

    # Set char index
    movl $0, %ecx

    # Put the input strings in ebx and edx
    movl 8(%ebp), %ebx
    movl 12(%ebp), %edx

strcmp_loop_start:
    # Load the byte to be compared from both strings into al and ah
    movb (%ebx, %ecx, 1), %al
    movb (%edx, %ecx, 1), %ah

    # Compare the chars, any chars unmatching = no match
    cmpb %al, %ah
    jne strcmp_no_match

    # If they match but one is a null, string ends, it's a match
    cmpb $0, %al
    je strcmp_match

    cmpb $0, %ah
    je strcmp_match

    # Match but neither is a null, increment char index and loop again
    incl %ecx
    jmp strcmp_loop_start

strcmp_no_match:
    movl $0, %eax
    jmp strcmp_ret

strcmp_match:
    movl $1, %eax

strcmp_ret:
    movl %ebp, %esp
    popl %ebp
    ret
