.include "common.asm"

.section .data

    heap_begin: .long 0
    current_break: .long 0

    .equ HEADER_SIZE, 8
    .equ HDR_AVAIL_OFFSET, 0
    .equ HDR_SIZE_OFFSET, 4

    .equ UNAVAILABLE, 0
    .equ AVAILABLE, 1

.section .text

#   Function allocate_init
#       Initialize the memory management system.

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

# Call allocate_init if necessary
    movl heap_begin, %eax
    cmpl $0, heap_begin
    jne allocate_init_done

    call allocate_init

allocate_init_done:

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


#   Function reallocate
#       Reallocate a segment of memory with a new size.
#
#   Stack arguments:
#       SEGMENT_ADDR - The memory address to reallocate. Must have been
#                      previously allocated by the allocate function.
#       NEW_SIZE     - The new size in bytes to resize the segment to.
#
#   Return values:
#       eax          - 0 if failed, otherwise the new address of the segment.

.globl reallocate
.type reallocate, @function
.equ SEGMENT_ADDR, 12
.equ NEW_SIZE, 8
reallocate:
    pushl %ebp
    movl %esp, %ebp

# Don't bother reallocating if the size won't change
    movl NEW_SIZE(%esp), %eax
    movl SEGMENT_ADDR(%esp), %ebx
    subl $HEADER_SIZE, %ebx
    cmpl %eax, HDR_SIZE_OFFSET(%ebx)
    jne reallocate_size_change

# Size wouldn't change, return original address
    movl SEGMENT_ADDR(%esp), %eax
    jmp reallocate_ret

reallocate_size_change:

# Allocate a new segment of the requested size
    pushl NEW_SIZE(%esp)
    call allocate
    addl $4, %esp
    cmpl $0, %eax
    je reallocate_ret

# Figure out if the segment grew or shrunk
    movl SEGMENT_ADDR(%esp), %ebx
    subl $HEADER_SIZE, %ebx
    movl HDR_SIZE_OFFSET(%ebx), %ecx
    movl NEW_SIZE(%esp), %edx
    cmpl %ecx, %edx
    jg reallocate_size_increased

# Segment shrunk, only copy NEW_SIZE bytes
    movl %edx, %ecx

# Segment grew, copy the original number of bytes
reallocate_size_increased:

# Copy bytes from old segment to new
    addl $HEADER_SIZE, %ebx

reallocate_copy_loop:
    decl %ecx
    cmpl $0, %ecx
    jl reallocate_copy_loop_done

    movb (%ebx, %ecx, 1), %dl
    movb %dl, (%eax, %ecx, 1)

    jmp reallocate_copy_loop

reallocate_copy_loop_done:

# Mark the original segment available
    subl $HEADER_SIZE, %ebx
    movl $AVAILABLE, HDR_AVAIL_OFFSET(%ebx)

reallocate_ret:
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
