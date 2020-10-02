itoa:       ; void itoa(num, buff, size, radix, flag);
; num   変換する値
; buff  保存先バッファアドレス
; size  保存先バッファサイズ
; radix 基数（2, 8, 10, 16)
; flags 
;   B2: 空白を'0'で埋める
;   B1: '+/-'記号を付加する
;   B0: 値を符号付き変数として扱う

    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di


    mov ax, [bp + 4]    ; num
    mov cx, [bp + 8]    ; size
    mov si, [bp + 6]    ; buff

    mov di, si
    add di, cx
    dec di              ; di = &si[cx-1]

    mov bx, word [bp + 12]   ; flags

    ; 符号付き判定
    test bx, 0b0001     ; 論理積を計算、0ならZFをセット
.10Q:
    je .10E         ; E=Exit
    cmp ax, 0
.12Q:
    jge .12E
    or bx, 0b0010
.12E:
.10E:

    ; 符号出力判定
    test bx, 0b0010
.20Q:
    je .20E
    cmp ax, 0
.22Q:
    jge .22F
    neg ax
    mov [si], byte '-'
    jmp .22E
.22F:
    
    mov [si], byte '+'
.22E:
    dec cx
.20E:

    ; ASCII変換
    mov bx, [bp + 10]   ; radix(基数)
.30L:
    mov dx, 0
    div bx      ; 商：ax, あまり: dx

    mov si, dx
    mov dl, byte [.ascii + si]

    mov [di], dl
    dec di

    cmp ax, 0
    loopnz .30L
.30E:

    cmp cx, 0
.40Q:
    je .40E
    mov al, ' '
    cmp [bp + 12], word 0b0100
.42Q:
    jne .42E
    mov al, '0'
.42E:
    std         ; dimention flag = 1(-方向)
    rep stosb   ; while (--cx) *di-- = al;
.40E:

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp

    ret

.ascii db "0123456789ABCDEF"    ; 変換テーブル
