draw_rotation_bar:
    push eax

    mov eax, [TIMER_COUNT]  ; タイマー割り込みカウンタ
    shr eax, 4              ; eax /= 4
    cmp eax, [.index]       ; if(eax == 前回値) goto .10E
    je .10E

    mov [.index], eax       ; 前回値設定
    and eax, 0x03           ; 前回値を0~3に正規化

    mov al, [.table + eax]  ; 文字表示
    cdecl draw_char, 0, 29, 0x000F, eax

.10E:

    pop eax

    ret

ALIGN 4, db 0
.index: dd 0        ; 前回値
.table: db "|/-\"   ; 表示キャラクタ
