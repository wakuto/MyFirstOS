itoa:       ; void itoa(num, buff, size, radix, flag);
; num   変換する値
; buff  保存先バッファアドレス
; size  保存先バッファサイズ
; radix 基数（2, 8, 10, 16)
; flags 
;   B2: 空白を'0'で埋める
;   B1: '+/-'記号を付加する
;   B0: 値を符号付き変数として扱う

    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi


    ; 引数取得
    mov eax, [ebp + 8]    ; num
    mov esi, [ebp +12]    ; size
    mov ecx, [ebp +16]    ; buff

    mov edi, esi
    add edi, ecx
    dec edi              ; edi = &esi[ecx-1]

    mov ebx, [ebp +24]   ; flags

    ; 符号付き判定
    test ebx, 0b0001     ; 論理積を計算、0ならZFをセット
.10Q:
    je .10E         ; E=Exit
    cmp eax, 0
.12Q:
    jge .12E
    or ebx, 0b0010
.12E:
.10E:

    ; 符号出力判定
    test ebx, 0b0010
.20Q:
    je .20E
    cmp eax, 0
.22Q:
    jge .22F
    neg eax
    mov [esi], byte '-'
    jmp .22E
.22F:
    
    mov [esi], byte '+'
.22E:
    dec ecx
.20E:

    ; ASCII変換
    mov ebx, [ebp +20]   ; radix(基数)
.30L:
    mov edx, 0
    div ebx      ; 商：ax, あまり: dx

    mov esi, edx
    mov dl, byte [.ascii + esi]

    mov [edi], dl
    dec edi

    cmp eax, 0
    loopnz .30L
.30E:

    ; 空欄を埋める
    cmp ecx, 0  ; 空白なしならgoto .40E
.40Q:
    je .40E
    mov al, ' '
    cmp [ebp +24], dword 0b0100
.42Q:
    jne .42E
    mov al, '0'
.42E:
    std         ; dimention flag = 1(-方向)
    rep stosb   ; while (--ecx) *edi-- = al;
.40E:

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret

.ascii db "0123456789ABCDEF"    ; 変換テーブル
