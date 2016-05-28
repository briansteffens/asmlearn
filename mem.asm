.include "common.inc"

.section .data

    heap_begin: .long 0
    current_break: .long 0

    .equ HEADER_SIZE, 8
    .equ HDR_AVAIL_OFFSET, 0
    .equ HDR_SIZE_OFFSET, 4

    .equ UNAVAILABLE, 0
    .equ AVAILABLE, 1

.section .text

.global allocate_init
.type allocate_init, @function
allocate_init:
    pushl %ebp
    movl %esp, %ebp

# Look up the current break
    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX

# Store the first valid address
    incl %eax
    movl %eax, current_break

# Same value is the heap_begin
    movl %eax, heap_begin

    movl %ebp, %esp
    popl %ebp
    ret


#   Function allocate
#       Allocate a segment of memory on the heap.
#
#   Stack arguments:
#       MEM_SIZE  - The number of bytes to allocate
#
#   Return values:
#       eax       - 0 if failed, otherwise the address of the newly-allocated
#                   segment.

.globl allocate
.type allocate, @function
.equ ST_MEM_SIZE, 8         # Stack position of memory size to allocate
allocate:
    pushl %ebp
    movl %esp, %ebp

# Input parameter - bytes to allocate
    movl ST_MEM_SIZE(%ebp), %ecx

# Current search position, looking for a block to reuse
    movl heap_begin, %eax

# Current break
    movl current_break, %ebx


# Each iteration of this loop inspects a memory block looking for an available
# one with enough space to satisfy the request.
allocate_loop:

# If we get to the end of the allocated memory without finding a candidate,
# request more memory from the OS.
    cmpl %ebx, %eax
    je allocate_more

# Get the size of this block
    movl HDR_SIZE_OFFSET(%eax), %edx

# Continue if the block is unavailable
    cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
    je allocate_next_block

# Block is available. See if it's big enough for the request.
    cmpl %edx, %ecx
    jle allocate_here


allocate_next_block:

# Move the pointer past this block and to the next one.
    addl $HEADER_SIZE, %eax
    addl %edx, %eax
    jmp allocate_loop


allocate_here:

# Mark the block as unavailable
    movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)

# Return the actual data, not the header
    addl $HEADER_SIZE, %eax

    jmp allocate_ret


allocate_more:

# Move past the last block
    addl $HEADER_SIZE, %ebx
    addl %ecx, %ebx

    pushl %eax
    pushl %ecx
    pushl %ebx

# Request more memory from OS
    movl $SYS_BRK, %eax
    int $LINUX

# If 0, OS is out of memory or just hates us, something like that!
    cmpl $0, %eax
    je allocate_err

    popl %ebx
    popl %ecx
    popl %eax

# Mark block as unavailable
    movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)

# Set memory size
    movl %ecx, HDR_SIZE_OFFSET(%eax)

# Move to start of actual memory
    addl $HEADER_SIZE, %eax

# Save new break point
    movl %ebx, current_break

    jmp allocate_ret


allocate_err:
    movl $0, %eax


allocate_ret:
    movl %ebp, %esp
    popl %ebp
    ret


#   Function deallocate
#       Free a segment of memory previously allocated by the allocate function
#
#   Stack arguments:
#       MEMORY_ADDR - The address of the segment to free.

.globl deallocate
.type deallocate, @function
.equ ST_MEMORY_ADDR, 4
deallocate:

# Grab input parameter (address of block to free)
    movl ST_MEMORY_ADDR(%esp), %eax

# Rewind the pointer to the block's header
    subl $HEADER_SIZE, %eax

# Mark segment available
    movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)

    ret
