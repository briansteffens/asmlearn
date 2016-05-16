.section .data

data_items:
    .long 3,67,34,238,45,75,54,34,44,33,22,11,66,0

.section .text

.globl _start
_start:
    movl $0, %edi       # index register starts at 0
    movl $255, %ebx       # min number starts at 255

start_loop:
    movl data_items(,%edi,4), %eax  # Load next value
    incl %edi           # increment array index for next loop iteration

    cmpl $0, %eax       # check for null-termination value
    je loop_exit        # exit if so

    cmpl %ebx, %eax     # compare value to current 'min'
    jge start_loop      # continue if value is not the new max

    movl %eax, %ebx     # set min to new value
    jmp start_loop

loop_exit:
    # %ebx is the exit status code and it already has the min number
    movl $1, %eax                    # exit command
    int $0x80
