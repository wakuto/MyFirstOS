draw_font:  ; void draw_font(col, row);
; col 列
; row 行
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edi
    push esi


    mov esi, [ebp + 8]  ; x
    mov edi, [ebp +12]  ; y

    mov ecx, 0
.10L:
    cmp ecx, 256
    jae .10E

    mov eax, ecx
    and eax, 0x0F   ; eax = 繰り返し回数の下位4ビット
    add eax, esi    ; eax += x

    mov ebx, ecx
    shr ebx, 4      ; eax = 繰り返し回数/16
    add ebx, edi    ; ebx += y

    cdecl draw_char, eax, ebx, 0x07, ecx

    inc ecx
    jmp .10L
.10E:

    pop esi
    pop edi
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret
