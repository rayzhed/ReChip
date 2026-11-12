bits 64
default rel

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
    ram resb    4096 ; 000->1FF fontes | 200->FFF ROM+DATA

section .text
    global main
    extern printf
    extern putchar
    extern fopen
    extern fread
    extern fclose
    %define file_ptr [rbp-24]
    %define read_rom [rbp-32]

main:
    push    rbp     ; prologue
    mov rbp,    rsp
    push rbx
    sub rsp, 24

    lea rdi,    [file] ; open file to read
    lea rsi,    [mode]
    call    fopen  wrt ..plt
    test    rax,    rax
    jz  .error

    mov file_ptr,   rax

    lea rdi,    [success] ; print file opened
    xor eax,    eax
    call    printf  wrt ..plt

    lea rdi,    [ram + 0x200]
    mov rsi,    1
    mov rdx,    3584
    mov rcx,    file_ptr
    call    fread   wrt ..plt ; read file content
    mov read_rom,  rax

    mov rsi,    read_rom
    lea rdi,    [fmt_size]
    xor eax,    eax
    call printf wrt ..plt ; display file size


    mov rbx,    0x200
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
    cmp rbx,    0x210 ; comp to 16

    jb .loop
    


    .loop_end:
    mov edi,    0xA ;
    call putchar wrt ..plt

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
    lea rsp,    [rbp-8] ; epilogue
    pop rbx
    pop rbp
    ret
    %undef file_ptr
    %undef read_rom