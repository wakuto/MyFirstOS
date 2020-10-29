draw_pixel:     ; void draw_pixel(x, y, color);
; x: X座標
; y: Y座標
; color: 描画色
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edi



    ; y座標*80->y*(640/8)
    mov edi, [ebp +12]
    shl edi, 4
    lea edi, [edi * 4 + edi + 0x0A_0000]

    ; x座標/8  8pixel単位の位置
    mov ebx, [ebp + 8]
    mov ecx, ebx
    shr ebx, 3
    add edi, ebx

    ; x座標を8で割った余りからビット位置を計算
    ; 8pixel中の位置
    ; 0=0b1000_0000, 1=0b0100_0000, ... , 7=0b0000_0001
    and ecx, 0x07   ; 下位3ビットは8で割ったときの余り
    mov ebx, 0x80
    shr ebx, cl

    mov ecx, [ebp +16]

    ; プレーンごとに出力
    cdecl vga_set_read_plane, 0x03              ; 輝度（I）プレーンを選択
    cdecl vga_set_write_plane, 0x08             ; 輝度（I）プレーンを選択
    cdecl vram_bit_copy, ebx, edi, 0x08, ecx 

    cdecl vga_set_read_plane, 0x02              ; Rプレーンを選択
    cdecl vga_set_write_plane, 0x04             ; Rプレーンを選択
    cdecl vram_bit_copy, ebx, edi, 0x04, ecx 

    cdecl vga_set_read_plane, 0x01              ; Gプレーンを選択
    cdecl vga_set_write_plane, 0x02             ; Gプレーンを選択
    cdecl vram_bit_copy, ebx, edi, 0x02, ecx 

    cdecl vga_set_read_plane, 0x00              ; Bプレーンを選択
    cdecl vga_set_write_plane, 0x01             ; Bプレーンを選択
    cdecl vram_bit_copy, ebx, edi, 0x01, ecx 

    pop edi
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret
