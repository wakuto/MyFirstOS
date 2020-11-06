int_keyboard:
    pusha
    push ds
    push es

    ; データ用セグメントの設定
    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    ; KBCのバッファ読み取り
    in al, 0x60

    ; キーコードの保存
    cdecl ring_wr, _KEY_BUFF, eax

    ; 割り込み終了コマンド送信
    outp 0x20, 0x20

    pop es
    pop ds
    popa

    iret

ALIGN 4, db 0
_KEY_BUFF: times ring_buff_size db 0
