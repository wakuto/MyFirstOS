KBC_Data_Write:     ; int KBC_Data_Write(data);
; data: 書き込みデータ
; 返り値 成功（0以外）失敗（0）
    push bp
    mov bp, sp

    push cx

    mov cx, 3
.10L:
    in al, 0x64     ; al = input(0x64) KBCステータス
    test al, 0x02   ; zf = al & 0x02   書き込み可能か？ zf != 0のときに書き込める
    loopnz .10L

    cmp cx, 0       ; タイムアウトしたらgoto .20E
    jz .20E

    mov al, [bp + 4]    ; 引数をkbcに書き込み
    out 0x60, al

.20E:
    mov ax, cx      ; 残り試行回数が返り値

    pop cx

    mov sp, bp
    pop bp

    ret


KBC_Data_Read:      ; int KBC_Data_read(data);
; data 読み込みデータ格納アドレス
; 返り値 成功（0以外）失敗（0）
    push bp
    mov bp, sp

    push ax
    push cx
    push di

    mov cx, 3
.10L:
    in al, 0x64
    test al, 0x01       ; 出力バッファフルを確認 zf == 1 のときに読み込める
    loopz .10L

    cmp cx, 0   ; タイム・アウトしたらgoto .20E
    jz .20E

    mov ah, 0x00
    in al, 0x60

    mov di, [bp + 4]
    mov [di + 0], ax

.20E:
    mov ax, cx

    pop di
    pop cx
    pop ax

    mov sp, bp
    pop bp

    ret


KBC_Cmd_Write:      ; int KBC_Cmd_Write(cmd);
; cmd: 書き込みコマンド
; 返り値 成功（0以外）失敗（0）
    push bp
    mov bp, sp

    push cx

    mov cx, 3
.10L:
    in al, 0x64     ; al = input(0x64) KBCステータス
    test al, 0x02   ; zf = al & 0x02   書き込み可能か？ zf != 0のときに書き込める
    loopnz .10L

    cmp cx, 0       ; タイムアウトしたらgoto .20E
    jz .20E

    mov al, [bp + 4]    ; 引数をkbcに書き込み
    out 0x64, al

.20E:
    mov ax, cx      ; 残り試行回数が返り値

    pop cx

    mov sp, bp
    pop bp

    ret
