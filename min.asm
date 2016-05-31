section .data

    data_items dq 3,67,34,238,45,75,54,34,2,33,22,11,66,0

section .text

global _start
_start:
    mov rdi, 0         ; index register starts at 0
    mov rbx, 255       ; min number starts at 255

start_loop:
    mov rax, [data_items + rdi * 8] ; Load next value
    inc rdi            ; increment array index for next loop iteration

    cmp rax, 0         ; check for null-termination value
    je loop_exit       ; exit if so

    cmp rax, rbx       ; compare value to current 'min'
    jge start_loop     ; continue if value is not the new max

    mov rbx, rax       ; set min to new value
    jmp start_loop

loop_exit:
    ; rbx is the exit status code and it already has the min number
    mov rax, 1         ; exit command
    int 0x80
