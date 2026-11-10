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
    fmt_byte   db  "%02x",  0x20,    0
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


    xor rbx,    rbx
    .loop:   ; display first byte
    lea rdx,    [rel ram + 0x200]
    movzx esi,  BYTE    [rdx + rbx]
    lea rdi,    [fmt_byte]
    xor eax,    eax
    call printf wrt ..plt
    inc rbx
    cmp rbx,    0x10 ; comp to 16

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