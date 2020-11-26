find_rsdt_entry:
; facp: RSDTテーブルのアドレス
; word: テーブル識別子
; 戻り値: 見つかったアドレス、見つからなかった場合は0
    push ebp
    mov ebp, esp

    push ebx
    push ecx
    push esi
    push edi

    mov esi, [ebp + 8]  ; RSDT
    mov ecx, [ebp +12]  ; 名前
    mov ebx, 0          ; adr = 0

    ; ACPIテーブル検索処理
    mov edi, esi
    add edi, [esi + 4]  ; EDI = テーブル長
    add esi, 36         ; ESI = エントリの開始アドレス
.10L:
    cmp esi, edi
    jge .10E

    lodsd               ; eax = [esi++]

    cmp [eax], ecx
    jne .12E            ; if(!テーブル名一致) goto .12E
    mov ebx, eax
    jmp .10E            ; if(テーブル名一致) ebx = アドレス
.12E:
    jmp .10L
.10E:

    mov eax, ebx        ; 戻り値 = ebx

    pop edi
    pop esi
    pop ecx
    pop ebx

    mov esp, ebp
    pop ebp

    ret

