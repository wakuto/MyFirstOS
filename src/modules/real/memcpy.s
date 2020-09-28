memcpy:     ; void memcpy(src, dest, size);
    push bp
    mov bp, sp

    push cx
    push si
    push di

    cld     ; clear direction flag
    mov si, [bp + 4]    ; src
    mov di, [bp + 6]    ; dest
    mov cx, [bp + 8]    ; size

    rep movsb

    pop di
    pop si
    pop cx

    mov sp, bp
    pop bp

    ret
