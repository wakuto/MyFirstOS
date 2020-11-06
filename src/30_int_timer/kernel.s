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

    ; 初期化
    cdecl init_int                  ; 割り込みベクタの初期化
    cdecl init_pic                  ; 割り込みコントローラの初期化

    set_vect 0x00, int_zero_div     ; 割り込み処理の登録：0除算
    set_vect 0x20, int_timer        ; 割り込み処理の登録：タイマー
    set_vect 0x21, int_keyboard     ; 割り込み処理の登録：KBC
    set_vect 0x28, int_rtc          ; 割り込み処理の登録：RTC

    ; デバイスの割り込み許可
    cdecl rtc_int_en, 0x10          ; rtc_int_en(UIE) 更新サイクル終了前割り込み許可

    ; IMR（割り込みマスクレジスタ）の設定
    outp 0x21, 0b1111_1000          ; 割り込み有効：スレーブPIC/KBC/タイマー
    outp 0xA1, 0b1111_1110          ; 割り込み有効：RTC

    sti                             ; 割り込み許可

    cdecl draw_font, 63, 13         ; フォント一覧表示
    cdecl draw_color_bar, 63, 4     ; カラーバーを表示
    cdecl draw_str, 25, 14, 0x010F, .s0 ; 文字の表示


.10L:
    cdecl draw_rotation_bar
    cdecl ring_rd, _KEY_BUFF, .int_key
    cmp eax, 0
    je .10E
    cdecl draw_key, 2, 29, _KEY_BUFF

    jmp .10L
.10E:

    ; 処理の終了
    jmp $

.s0 db " Hello, kernel! ", 0

ALIGN 4, db 0
.int_key: dd 0

ALIGN 4, db 0
FONT_ADR: dd 0
RTC_TIME: dd 0

; モジュール
%include "../modules/protect/vga.s"
%include "../modules/protect/draw_char.s"
%include "../modules/protect/draw_font.s"
%include "../modules/protect/draw_str.s"
%include "../modules/protect/draw_color_bar.s"
%include "../modules/protect/draw_pixel.s"
%include "../modules/protect/draw_line.s"
%include "../modules/protect/draw_rect.s"
%include "../modules/protect/itoa.s"
%include "../modules/protect/rtc.s"
%include "../modules/protect/draw_time.s"
%include "../modules/protect/interrupt.s"
%include "../modules/protect/pic.s"
%include "../modules/protect/int_rtc.s"
%include "../modules/protect/int_keyboard.s"
%include "../modules/protect/ring_buff.s"
%include "../modules/protect/timer.s"
%include "../modules/protect/draw_rotation_bar.s"
%include "modules/int_timer.s"

;パディング
    times KERNEL_SIZE - ($ - $$) db 0

