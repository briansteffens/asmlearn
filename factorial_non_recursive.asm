section .text

global _start
_start:
    push 5
    call factorial
    add rsp, 8
    mov rbx, rax

    mov rax, 1
    int 0x80

global factorial
factorial:
    push rbp
    mov rbp, rsp

    mov rcx, [rbp + 16]     ; Input argument -> rcx
    mov rax, 1              ; 1 -> rax

factorial_loop:
    imul rax, rcx
    loop factorial_loop

    mov rsp, rbp
    pop rbp
    ret
