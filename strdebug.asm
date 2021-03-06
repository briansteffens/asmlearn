%include "common.asm"

extern int_to_str

section .bss

    BUFFER_LEN equ 11
    BUFFER resb BUFFER_LEN

section .data

    PARAM_INPUT equ 24
    PARAM_INPUT_LEN equ 16

    LOCAL_BYTES equ 8
    LOCAL_INDEX equ -8

    ASCII_LF equ 10

section .text

;   Function strdebug
;       Prints out a string's chars in ASCII format for debugging purposes.
;
;   Stack arguments:
;       INPUT     - The string to output
;       INPUT_LEN - The number of characters in INPUT to consider part of the
;                   string
;
;   Return values:
;       rax       - 0 if success, otherwise failure

global strdebug:function
strdebug:
    push rbp
    mov rbp, rsp
    sub rsp, LOCAL_BYTES

    mov rcx, 0

strdebug_loop_start:
    mov rdx, [rbp + PARAM_INPUT_LEN]
    cmp rcx, rdx
    jge strdebug_done
    mov [rbp + LOCAL_INDEX], rcx

    mov rbx, [rbp + PARAM_INPUT]

    xor rax, rax
    mov al, [rbx + rcx]

    push rax
    push BUFFER
    call int_to_str
    add rsp, 16
    cmp rax, 0
    jne strdebug_err

    mov rdx, rbx
    mov rcx, BUFFER
    mov byte [rcx, rdx], ASCII_LF
    inc rdx

    mov rax, SYS_FILE_WRITE
    mov rbx, STDOUT
    int LINUX
    cmp rax, 0
    jl strdebug_err

    mov rcx, [rbp + LOCAL_INDEX]
    inc rcx

    jmp strdebug_loop_start

strdebug_err:
    mov rax, -1
    jmp strdebug_ret

strdebug_done:
    mov rax, 0

strdebug_ret:
    mov rsp, rbp
    pop rbp
    ret
