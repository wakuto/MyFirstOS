memcmp:     ; int memcmp(src0, src1, size);
    push bp
    mov bp, sp

    push bx
    push cx
    push dx
    push si
    push di

    cld
    mov si, [bp + 4]
    mov di, [bp + 6]
    mov cx, [bp + 8]

    reqe cmpsb  ; siとdiを比較して１加算or減算する
    jnz .10F
    mov ax, 0
    jmp .10E

.10F:
    mov ax, -1

.10E:

    pop di
    pop si
    pop dx
    pop cx
    pop bx

    mov sp, bp
    pop bp

    ret

