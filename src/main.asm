bits 64
default rel

section .data

section .rodata

file    db  "roms/tests/test_opcode.ch8", 0
failed     db  "Error : can't find your bleblefile", 0xA, 0
success     db  "File Opened pirate!",  0xA,    0
mode db "rb", 0

section .text
global main
extern printf
extern fopen
extern fclose

%define file_ptr [rbp-8]

main:
    push    rbp     ; prologue
    mov rbp,    rsp
    sub rsp, 16

    lea rdi,    [file] ; open file to read
    lea rsi,    [mode]
    call    fopen  wrt ..plt
    test    rax,    rax
    jz  .error

    mov file_ptr,   rax

    lea rdi,    [success] ; print file opened
    xor eax,    eax
    call    printf  wrt ..plt
    mov rdi, file_ptr
    call    fclose  wrt ..plt
    xor eax,    eax
    jmp .done

    
    .error:
    lea rdi,    [failed] ; print file cant be opened
    xor eax,    eax
    call    printf  wrt ..plt
    mov eax,    1



    .done:
    mov rsp,    rbp ; epilogue
    pop rbp
    ret
    %undef file_ptr