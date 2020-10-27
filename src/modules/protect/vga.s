vga_set_read_plane:     ; void vga_set_read_plane(plane);
; plane: 読み込みプレーン
    push ebp
    mov ebp, esp

    push ax
    push dx


    ; 読み込みプレーンの選択
    mov ah, [ebp + 8]   ; 3=輝度, 2～0=RGB
    and ah, 0x03        ; 余計なビットをマスク
    mov al, 0x04        ; 読み込みマップ選択レジスタ
    mov dx, 0x03CE      ; グラフィックス制御ポート
    out dx, ax

    pop dx
    pop ax

    mov esp, ebp
    pop ebp

    ret

vga_set_write_plane:    ; void vga_set_write_plane(plane);
; plane 書き込みプレーン
    push ebp
    mov ebp, esp

    push ax
    push dx


    ; 書き込みプレーンの選択
    mov ah, [ebp + 8]   ; ah = 書き込みプレーン
    and ah, 0x0F        ; 余計なビットをマスク
    mov al, 0x02        ; マップマスクレジスタ（書き込みプレーンを指定）
    mov dx, 0x03C4      ; シーケンサ制御ポート
    out dx, ax


    pop dx
    pop ax

    mov esp, ebp
    pop ebp

    ret

vram_font_copy:         ; void vram_font_copy(font, vram, plane, color);
; font FONTアドレス
; vram VRAMアドレス
; plane 出力プレーン（1つのプレーンのみをビットで指定）
; color 描画色 背景色(----IRGB):前景色(---TIRGB) T=透過, I=輝度
    push ebp
    mov ebp, esp
    
    push eax
    push ebx
    push edx
    push edi
    push esi

    mov esi, [ebp + 8]          ; font
    mov edi, [ebp + 12]         ; vram
    movzx eax, byte [ebp + 16]  ; plane
    movzx ebx, word [ebp + 20]  ; color
    ; bh = 背景色 bl = 前景色

    test bh, al     ; zf = (背景色 & プレーン）
    setz dh         ; dh = zf
    dec dh          ; 背景色が含まれる：dh = 0xFF, 含まれない：dh = 0x00

    test bl, al     ; zf = （前景色 & プレーン）
    setz dl         ; dl = zf
    dec dl          ; 前景色が含まれる：dl = 0xFF, 含まれない：dl = 0x00

    ; 16ドットフォントのコピー
    cld             ; アドレス加算モード

    mov ecx, 16
.10L:
    ; フォントマスクの作成
    lodsb           ; al = *(esi++) // フォントデータ1ビット分
    mov ah, al      ; ah ~= al      // !フォントデータ
    not ah

    ; 前景色
    and al, dl      ; al = プレーン&前景色ありorなし

    ; 背景色
    test ebx, 0x0010    ; if(透過on) zf = 0; else zf = 1;
    jz .11F
    ; 透過on
    and ah, [edi]       ; 現在のデータでフォントデータをマスク
    jmp .11E
.11F:                   ; 透過off
    and ah, dh          ; if(背景色なし) ah = 0;
.11E:
    
    ; 前景色と背景色を合成
    or al, ah           ; al = 背景 | 前景

    ; 新しい値を出力
    mov [edi], al

    add edi, 80      ; 1行すすめる
    loop .10L
.10E:

    pop esi
    pop edi
    pop edx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret
