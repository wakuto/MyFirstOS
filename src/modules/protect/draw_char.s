draw_char:      ; void draw_char(col, row, color, ch);
; col 列（0～79）
; row 行（0～29）
; color 描画色 背景色(----IRGB):前景色(---TIRGB) T=透過, I=輝度
; ch 文字

    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi

    ; コピー元フォントアドレスを設定
    movzx esi, byte [ebp +20]  ; esi = ch
    shl esi, 4                  ; ch * 16   1文字16バイト
    add esi, [FONT_ADR]         ; ESI = フォントアドレス

    ; コピー先アドレスを取得
    ; adr = 0xA0000 + (640 / 8 * 16) * y + x
    ;               16行(1文字の高さ）  *  縦位置 + 横位置
    mov edi, [ebp +12]                  ; Y
    shl edi, 8
    lea edi, [edi * 4 + edi + 0xA0000]  ; Y * 16行
    add edi, [ebp + 8]                  ; edi += X

    ; 1文字分のフォントを出力
    movzx ebx, word [ebp +16]           ; 表示色

    ; 輝度I
    cdecl vga_set_read_plane, 0x03      ; 輝度プレーン
    cdecl vga_set_write_plane, 0x08     ; 輝度プレーン
    cdecl vram_font_copy, esi, edi, 0x08, ebx

    ; 赤R
    cdecl vga_set_read_plane, 0x02      ; 赤プレーン
    cdecl vga_set_write_plane, 0x04     ; 赤輝度プレーン
    cdecl vram_font_copy, esi, edi, 0x04, ebx

    ; 緑G
    cdecl vga_set_read_plane, 0x01      ; 緑プレーン
    cdecl vga_set_write_plane, 0x02     ; 緑プレーン
    cdecl vram_font_copy, esi, edi, 0x02, ebx

    ; 青B
    cdecl vga_set_read_plane, 0x00      ; 青プレーン
    cdecl vga_set_write_plane, 0x01     ; 青プレーン
    cdecl vram_font_copy, esi, edi, 0x01, ebx

    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp

    ret
