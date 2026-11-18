bits 64
default rel
%include "chip8.inc"

section .data

section .rodata
    ; name  type    data
    file    db  "roms/tests/test_opcode.ch8", 0
    failed     db  "Error : can't find your bleblefile", 0xA, 0
    success     db  "File Opened pirate!",  0xA,    0
    mode db "rb", 0

    fmt_size   db  "%lu",  0xA,    0
    fmt_opcode   db  "%04x",  0x20,    0
    fmt_decode    db  "NNN=%03x NN=%02x N=%01x Y=%01x X=%01x", 0xA, 0
section .bss
    ; name  type    size
    ram resb    RAM_SIZE ; 000->1FF fontes | 200->FFF ROM+DATA

section .text
    global main
    extern printf
    extern putchar
    extern fopen
    extern fread
    extern fclose

main:
    push    rbp     ; prologue
    mov rbp,    rsp
    push rbx
    sub rsp,    8


    lea rdi,    [file] ;path
    lea rsi,    [ram + ROM_START] ;dest
    mov rdx,    ROM_MAX_SIZE ;max size
    call load_rom
    test rax,   rax
    jle .error

    mov rsi,    rax
    lea rdi,    [fmt_size]
    xor eax,    eax
    call printf wrt ..plt ; display file size


    mov rbx,    ROM_START
    .loop:   ; display words byte

    lea rdx,    [rel ram]
    movzx esi, WORD    [rdx + rbx]
    rol si,    8

    mov r10d, esi
    and esi, 0x0FFF

    mov edx, r10d
    and edx, 0x00FF


    mov ecx, r10d
    and ecx, 0x000F

    mov r8d, r10d
    shr r8d, 4
    and r8d, 0x000F

    mov r9d, r10d
    shr r9d, 8
    and r9d, 0x000F


    lea rdi,    [fmt_decode]
    xor eax,    eax
    call printf wrt ..plt


    add rbx, 0x2
    cmp rbx,    ROM_START + 8*2 ; comp up to 8 opcodes

    jb .loop
    


    .loop_end:
    mov edi,    0xA ;
    call putchar wrt ..plt
    xor eax,    eax
    jmp .done

    
    .error:
    lea rdi,    [failed] ; print file cant be opened
    xor eax,    eax
    call    printf  wrt ..plt
    mov eax,    1



    .done:
    lea rsp,    [rbp-8] ; epilogue
    pop rbx
    pop rbp
    ret

load_rom:
    push    rbp     ; prologue
    mov rbp,    rsp
    push rbx    ;dest
    push r12    ;max size
    push r13    ;FILE*
    push r14    ;read size

    mov rbx,    rsi ;dest
    mov r12,    rdx ; max size

    lea rsi,    [mode]
    call    fopen  wrt ..plt
    test    rax,    rax
    jz  .error_file

    mov r13,    rax ; FILE*

    mov rdi,    rbx
    mov rsi,    1
    mov rdx,    r12
    mov rcx,    r13
    call    fread   wrt ..plt ; read file content
    mov r14,  rax   ; read size

    mov rdi, r13
    call    fclose  wrt ..plt
    mov rax,    r14
    test    rax,    rax
    jz  .error_size

    jmp .end
        
    .error_file:
    mov rax,   -1
    jmp .end

    .error_size:
    mov rax,   -2

    .end:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
