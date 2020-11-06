ring_rd:        ; int ring_rd(buff, data);
; buff リングバッファ
; data 読み込んだデータの保存先アドレス
; 戻り値: データあり(0以外), データなし(0)

    push ebp
    mov ebp, esp

    push eax
    push ebx
    push esi
    push edi

    ; 引数取得
    mov esi, [ebp + 8]  ; リングバッファ
    mov edi, [ebp +12]  ; データアドレス

    ; 読み込み位置を確認
    mov eax, 0                      ; 戻り値データなし
    mov ebx, [esi + ring_buff.rp]
    cmp ebx, [esi + ring_buff.wp]
    je .10E                         ; if(rp == wp) goto .10E

    mov al, [esi + ring_buff.item + ebx]    ; データを保存

    mov [edi], al

    inc ebx ; 次の読み込み位置
    and ebx, RING_INDEX_MASK    ; サイズの制限
    mov [esi + ring_buff.rp], ebx   ; 読み込み位置を保存

    mov eax, 1                      ; 戻り値データあり
.10E:

    pop edi
    pop esi
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret


ring_wr:    ; int ring_wr(buff, data);
; buff シリンダバッファ
; data 書き込むデータ
; 戻り値: 成功(0以外), 失敗(0)
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push esi

    mov esi, [ebp + 8]  ; esi = リングバッファ

    ; 書き込み位置を確認
    mov eax, 0      ; 戻り値 失敗
    mov ebx, [esi + ring_buff.wp]   ; 書き込み位置
    mov ecx, ebx
    inc ecx                         ; 次の書き込み位置
    and ecx, RING_INDEX_MASK        ; サイズの制限

    ; バッファフルなら処理しない
    cmp ecx, [esi + ring_buff.rp]   ; if(次の書き込み位置==読み込み位置) goto .10E
    je .10E

    mov al, [ebp +12]   ; al = キーコード

    mov [esi + ring_buff.item + ebx], al    ; キーコード保存
    mov [esi + ring_buff.wp], ecx           ; 書き込み位置保存
    mov eax, 1  ; 戻り値 成功
.10E:

    pop esi
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret

draw_key:
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi


    mov edx, [ebp + 8]  ; edx = x列
    mov edi, [ebp +12]  ; edi = y行
    mov esi, [ebp +16]  ; esi = リングバッファ

    ; リングバッファの情報を取得
    mov ebx, [esi + ring_buff.rp]   ; rp 読み込み位置
    lea esi, [esi + ring_buff.item] ; &KEY_BUFF[EBX]
    mov ecx, RING_ITEM_SIZE

.10L:
    dec ebx ; 読み込み位置
    and ebx, RING_INDEX_MASK    ; サイズの制限
    mov al, [esi + ebx]         ; バッファ取り出し

    cdecl itoa, eax, .tmp, 2, 16, 0x0100    ; キーコード->文字列
    cdecl draw_str, edx, edi, 0x02, .tmp    ; 文字列表示

    add edx, 3  ; 表示位置更新
    loop .10L
.10E:

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret

ALIGN 4, db 0
.tmp db "-- ", 0
