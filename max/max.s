.section .data

data_items:
    .long 3,67,34,238,45,75,54,34,44,33,22,11,66,0

.section .text

.globl _start
_start:
    movl $0, %edi                    # load 0 into index register
    movl data_items(, %edi, 4), %eax # load the first byte of data into eax
    movl %eax, %ebx                  # first number is always max so far

start_loop:
    cmpl $0, %eax                    # check for null-termination value
    je loop_exit                     # exit if so

    incl %edi                        # increment array index
    movl data_items(, %edi, 4), %eax # load next value

    cmpl %ebx, %eax                  # compare values
    jle start_loop                   # continue if value is not the new max

    movl %eax, %ebx                  # set max to new value
    jmp start_loop

loop_exit:
    # %ebx is the exit status code and it already has the max number
    movl $1, %eax                    # exit command
    int $0x80
