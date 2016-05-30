.include "common.asm"

.section .bss

    .equ BUFFER_LEN, 11
    .lcomm BUFFER, BUFFER_LEN

.section .data

    .equ PARAM_INPUT, 12
    .equ PARAM_INPUT_LEN, 8

    .equ LOCAL_BYTES, 4
    .equ LOCAL_INDEX, -4

.section .text

#   Function strdebug
#       Prints out a string's chars in ASCII format for debugging purposes.
#
#   Stack arguments:
#       INPUT     - The string to output
#       INPUT_LEN - The number of characters in INPUT to consider part of the
#                   string
#
#   Return values:
#       eax       - 0 if success, otherwise failure

.globl strdebug
.type strdebug, @function

strdebug:
    pushl %ebp
    movl %esp, %ebp
    subl $LOCAL_BYTES, %esp

    movl $0, %ecx

strdebug_loop_start:
    movl PARAM_INPUT_LEN(%ebp), %edx
    cmpl %edx, %ecx
    jge strdebug_done
    movl %ecx, LOCAL_INDEX(%ebp)

    movl PARAM_INPUT(%ebp), %ebx

    xor %eax, %eax
    movb (%ebx, %ecx, 1), %al

    pushl %eax
    pushl $BUFFER
    call int_to_str
    addl $8, %esp
    cmpl $0, %eax
    jne strdebug_err

    movl %ebx, %edx
    movl $BUFFER, %ecx
    movb $ASCII_LF, (%ecx, %edx, 1)
    incl %edx

    movl $SYS_FILE_WRITE, %eax
    movl $STDOUT, %ebx
    int $LINUX
    cmpl $0, %eax
    jl strdebug_err

    movl LOCAL_INDEX(%ebp), %ecx
    incl %ecx

    jmp strdebug_loop_start

strdebug_err:
    movl $-1, %eax
    jmp strdebug_ret

strdebug_done:
    movl $0, %eax

strdebug_ret:
    movl %ebp, %esp
    popl %ebp
    ret
