acpi_find:
; address: アドレス
; size:    サイズ
; word:    検索データ
; 戻り値 見つかったアドレス、見つからなかった場合は0

; 4byteの名前空間を検索する

    push ebp
    mov ebp, esp

    push ecx
    push edi

    ; 引数を取得
    mov edi, [ebp + 8]  ; address
    mov ecx, [ebp +12]  ; size
    mov eax, [ebp +16]  ; 検索データ

    ; 名前の検索
    cld
.10L:
    ; 最初の1バイトが一致するまで検索
    repne scasb         ; while(AL != *EDI) EDI++

    cmp ecx, 0
    jnz .11E            ; if(found) goto .11E
    mov eax, 0          ; if(not found) eax = 0
    jmp .10E            ; goto .10E
.11E:

    ; 一致した場合4バイトを比較する
    cmp eax, [es:edi - 1]   ; if(eax != *edi) goto .10L
    jne .10L

    dec edi     
    mov eax, edi    ; eax = edi - 1;  
.10E:

    pop edi
    pop ecx

    mov esp, ebp
    pop ebp
    ret
