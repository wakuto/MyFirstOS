draw_rect:  ; void draw_rect(x0, y0, x1, y1, color);
    push ebp
    mov ebp, esp
    
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov eax, [ebp + 8]  ; x0
    mov ebx, [ebp +12]  ; y0
    mov ecx, [ebp +16]  ; x1
    mov edx, [ebp +20]  ; y1
    mov esi, [ebp +24]  ; color

    ; 左上(x0, y0) 右下(x1, y1)にする
    cmp eax, ecx
    jl .10E
    xchg eax, ecx
.10E:
    cmp ebx, edx
    jl .20E
    xchg ebx, edx
.20E:

    ; 矩形を描画
    cdecl draw_line, eax, ebx, ecx, ebx, esi    ; 上線
    cdecl draw_line, eax, ebx, eax, edx, esi    ; 左線

    dec edx
    cdecl draw_line, eax, edx, ecx, edx, esi    ; 下線（1ドット上）
    inc edx

    dec ecx
    cdecl draw_line, ecx, ebx, ecx, edx, esi    ; 右線（1ドット左）

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    mov esp, ebp
    pop ebp

    ret
