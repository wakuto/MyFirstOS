puts:       ; void puts(str);
    push bp
    mov bp, sp

    push ax
    push bx
    push si

    mov si, [bp + 4]    ; si=文字列のアドレス

    mov ah, 0x0E
    mov bx, 0x0000
    cld

.10L:
    lodsb

    cmp al, 0x00
    je .10E

    int 0x10
    jmp .10L

.10E:
    pop si
    pop bx
    pop ax

    mov sp, bp
    pop bp

    ret
