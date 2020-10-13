get_font_adr:   ; void get_font_adr(adr)
; adr: フォントアドレス格納位置
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push es
    push bp

    mov si, [bp + 4]    ; si = adr
    
    mov ax, 0x1130      ; フォントアドレスの取得
    mov bh, 0x06        ; 8x16のフォント
    int 0x10
.10Q:
    jc .10F
.10T:   ; 成功
    mov [si + 0], es    ; adr[0] = セグメント
    mov [si + 2], bp    ; adr[1] = オフセット
    jmp .10E
.10F:   ; 失敗
    cdecl puts, .e0
    call reboot
.10E:
    pop bp
    pop es
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp

    ret

.e0 db "Can't get font data.", 0
