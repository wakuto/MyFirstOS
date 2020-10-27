%include "../include/define.s"
%include "../include/macro.s"

    ORG KERNEL_LOAD

[BITS 32]   ; 32bitコードを生成

; エントリポイント
kernel:
    ; フォントアドレスを取得
    mov esi, BOOT_LOAD + SECT_SIZE  ; 0x7C00 + 512  フォントアドレス
    movzx eax, word [esi + 0]       ; FONT.seg  セグメント
    movzx ebx, word [esi + 2]       ; FONT.off  オフセット
    shl eax, 4
    add eax, ebx
    mov [FONT_ADR], eax

    ; 8ビットの横線
    mov ah, 0x0F                    ; AH = 書き込みプレーンを指定(Bit:----IRGB)
    mov al, 0x02                    ; AL = マップマスクレジスタ（書き込みプレーンを指定）
    mov dx, 0x03C4                  ; DX = シーケンサ制御ポート
    out dx, ax

    mov [0x000A_0000 + 0], byte 0xFF

    mov ah, 0x04                    ; R
    out dx, ax

    mov [0x000A_0000 + 1], byte 0xFF

    mov ah, 0x02                    ; G
    out dx, ax

    mov [0x000A_0000 + 2], byte 0xFF

    mov ah, 0x01                    ; B
    out dx, ax

    mov [0x000A_0000 + 3], byte 0xFF

    ; 画面を横切る横線
    mov ah, 0x02                    ; G
    out dx, ax

    lea edi, [0x000A_0000 + 80]     ; 2行目のドットから
    mov ecx, 80                     ; 80byte分(640bit->640pixel->１行)
    mov al, 0xFF
    rep stosb                       ; *(EDI++) = AL

    ; 2行目に8ドットの矩形
    mov edi, 1                      ; 行数

    ; lea edi, [edi * 1280 + 0xA_0000]
    shl edi, 8
    lea edi, [edi * 4 + edi + 0xA_0000]

    mov [edi + (80 * 0)], word 0xFF
    mov [edi + (80 * 1)], word 0xFF
    mov [edi + (80 * 2)], word 0xFF
    mov [edi + (80 * 3)], word 0xFF
    mov [edi + (80 * 4)], word 0xFF
    mov [edi + (80 * 5)], word 0xFF
    mov [edi + (80 * 6)], word 0xFF
    mov [edi + (80 * 7)], word 0xFF

    ; 3行目に文字を描画
    mov esi, 'A'
    shl esi, 4
    add esi, [FONT_ADR]

    mov edi, 2                      ; 行数
    ; lea edi, [edi * 1280 + 0xA_0000]
    shl edi, 8
    lea edi, [edi * 4 + edi + 0xA_0000]

    mov ecx, 16
.10L:
    
    movsb                   ; *(EDI++) = *(ESI++)
    add edi, 80-1           ; 次の行
    loop .10L
    ; 処理の終了
    jmp $

ALIGN 4, db 0
FONT_ADR: dd 0

;パディング
    times KERNEL_SIZE - ($ - $$) db 0

