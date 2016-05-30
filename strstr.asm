.include "common.asm"

.section .text

.globl strstr
.type strstr, @function

strstr:
    pushl %ebp
    movl %esp, %ebp

    subl $4, %esp                  # Reserve local storage
    movl $-1, -4(%ebp)             # Haystack loop iterator

    movl $0, %edx                  # Haystack iterator

strstr_haystack_loop_start:
    movl -4(%ebp), %ecx            # Grab haystack iterator
    incl %ecx                      # Next haystack char
    movl %ecx, -4(%ebp)            # Save haystack iterator for next loop
    movl $0, %edx                  # Reset needle iterator

strstr_needle_loop_start:
    movl 12(%ebp), %ebx            # Load haystack
    movb (%ebx, %ecx, 1), %al      # Get haystack byte

    cmpb $0, %al                   # End of haystack => no match
    je strstr_end_no_match

    movl 8(%ebp), %ebx             # Load needle
    movb (%ebx, %edx, 1), %ah      # Get needle byte

    cmpb $0, %ah                   # End of needle => match
    je strstr_end_match

    incl %ecx                      # Next char
    incl %edx

    cmpb %al, %ah
    je strstr_needle_loop_start    # Matching so far, keep checking this offset

    jmp strstr_haystack_loop_start # No match, try next haystack offset

strstr_end_match:
    movl -4(%ebp), %eax            # Return haystack iterator
    jmp strstr_ret

strstr_end_no_match:
    movl $-1, %eax                 # Return -1
    jmp strstr_ret

strstr_ret:
    movl %ebp, %esp
    popl %ebp
    ret
