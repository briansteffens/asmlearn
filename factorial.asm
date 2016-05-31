section .text

global _start
_start:
    push 5
    call factorial
    add rsp, 8
    mov rbx, rax             ; factorial() return -> os exit code

    mov rax, 1
    int 0x80


global factorial
factorial:
    push rbp
    mov rbp, rsp

    mov rax, [rbp + 16]      ; Input argument -> eax

    cmp rax, 1               ; If input is down to 1, return 1 (base case)
    je factorial_return

    dec rax                  ; Decrement input argument

    push rax                 ; Make recursive call with decremented input arg
    call factorial
    add rsp, 8

    mov rbx, [rbp + 16]      ; Input arg -> ebx
    imul rax, rbx            ; Input arg * recursive result

factorial_return:
    mov rsp, rbp
    pop rbp
    ret
