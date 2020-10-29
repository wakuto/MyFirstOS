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

    cdecl draw_font, 63, 13         ; フォント一覧表示
    cdecl draw_color_bar, 63, 4     ; カラーバーを表示
    cdecl draw_str, 25, 14, 0x010F, .s0 ; 文字の表示

    ; 線を描画
    cdecl draw_line, 100, 100,   0,   0, 0x0F
    cdecl draw_line, 100, 100, 200,   0, 0x0F
    cdecl draw_line, 100, 100, 200, 200, 0x0F
    cdecl draw_line, 100, 100,   0, 200, 0x0F

    cdecl draw_line, 100, 100,  50,   0, 0x02
    cdecl draw_line, 100, 100, 150,   0, 0x03
    cdecl draw_line, 100, 100, 150, 200, 0x04
    cdecl draw_line, 100, 100,  50, 200, 0x05

    cdecl draw_line, 100, 100,   0,  50, 0x02
    cdecl draw_line, 100, 100, 200,  50, 0x03
    cdecl draw_line, 100, 100, 200, 150, 0x04
    cdecl draw_line, 100, 100,   0, 150, 0x05

    cdecl draw_line, 100, 100, 100,   0, 0x0F
    cdecl draw_line, 100, 100, 200, 100, 0x0F
    cdecl draw_line, 100, 100, 100, 200, 0x0F
    cdecl draw_line, 100, 100,   0, 100, 0x0F

    ; 処理の終了
    jmp $

.s0 db " Hello, kernel! ", 0

ALIGN 4, db 0
FONT_ADR: dd 0

; モジュール
%include "../modules/protect/vga.s"
%include "../modules/protect/draw_char.s"
%include "../modules/protect/draw_font.s"
%include "../modules/protect/draw_str.s"
%include "../modules/protect/draw_color_bar.s"
%include "../modules/protect/draw_pixel.s"
%include "../modules/protect/draw_line.s"

;パディング
    times KERNEL_SIZE - ($ - $$) db 0

