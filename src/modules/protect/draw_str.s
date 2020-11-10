draw_str:   ;void draw_str(col, row, color, p);
; col: 列
; row: 行
; color: 描画色
; p: 文字列のアドレス
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edx
    push esi


    mov ecx, [ebp + 8]  ; col
    mov edx, [ebp +12]  ; row
    movzx ebx, word [ebp + 16] ; color
    mov esi, [ebp +20]  ; p

    cld
.10L:
    lodsb
    cmp al, 0
    je .10E

%ifdef USE_SYSTEM_CALL
    int 0x81
%else
    cdecl draw_char, ecx, edx, ebx, eax
%endif

    inc ecx
    cmp ecx, 80
    jl .12E         ; 横はみ出してなければgoto .12E
    mov ecx, 0      ; はみ出してれば次の行へ
    inc edx
    cmp edx, 30
    jl .12E         ; 縦はみ出してなければgoto .12E
    mov edx, 0      ; はみ出してれば左上に戻る
.12E:
    jmp .10L
.10E:

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret
