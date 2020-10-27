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

    ; 文字の表示
    cdecl draw_char, 0, 0, 0x010F, 'A'
    cdecl draw_char, 1, 0, 0x010F, 'B'
    cdecl draw_char, 2, 0, 0x010F, 'C'

    cdecl draw_char, 0, 0, 0x0402, '0'
    cdecl draw_char, 1, 0, 0x0212, '1'
    cdecl draw_char, 2, 0, 0x0212, '_'

    ; 処理の終了
    jmp $

ALIGN 4, db 0
FONT_ADR: dd 0

; モジュール
%include "../modules/protect/vga.s"
%include "../modules/protect/draw_char.s"

;パディング
    times KERNEL_SIZE - ($ - $$) db 0

