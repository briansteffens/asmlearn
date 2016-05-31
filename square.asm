section .text

global _start
_start:
    push 5
    call square
    add esp, 8
    mov rbx, rax            ; square() return -> os exit code

    mov rax, 1
    int 0x80

global square
square:
    push rbp
    mov rbp, rsp

    mov rax, [rbp + 16]     ; Input argument -> rax
    mov rbx, rax            ; Input argument -> rbx
    imul rax, rbx           ; Input arg * input arg

    mov rsp, rbp
    pop rbp
    ret
