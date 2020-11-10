draw_line:  ; void draw_line(X0, Y0, X1, Y1, color);
; X0 始点のＸ座標
; Y0 始点のＹ座標
; X1 終点のX座標
; Y1 終点のY座標
; color 描画色
    push ebp        ; EBP+ 4| EIP(戻り番地)
    mov ebp, esp    ; EBP+ 0| EBP(元の値)
                    ; ----------------
    push dword 0    ;    - 4| sum   = 0
    push dword 0    ;    - 8| x0    = 0
    push dword 0    ;    -12| dx    = 0
    push dword 0    ;    -16| inc_x = 0
    push dword 0    ;    -20| y0    = 0
    push dword 0    ;    -24| dy    = 0
    push dword 0    ;    -28| inc_y = 0

    push eax        ;    -32| eax
    push ebx        ;    -36| ebx
    push ecx        ;    -40| ecx
    push edx        ;    -44| edx
    push esi        ;    -48| esi
    push edi        ;    -52| edi
    ; espはebp-52?

    ; x0とx1の距離を計算
    mov eax, [ebp + 8]
    mov ebx, [ebp +16]
    sub ebx, eax
    jge .10F

    neg ebx
    mov esi, -1
    jmp .10E
.10F:
    mov esi, 1
.10E:
    
    ; y0とy1の距離を計算
    mov ecx, [ebp +12]
    mov edx, [ebp +20]
    sub edx, ecx
    jge .20F

    neg edx
    mov edi, -1
    jmp .20E
.20F:
    mov edi, 1
.20E:
    
    ; x軸
    mov [ebp - 8], eax  ; 開始座標
    mov [ebp -12], ebx  ; 描画幅
    mov [ebp -16], esi  ; 増分(基準軸:1 or -1)

    ; y軸
    mov [ebp -20], ecx  ; 開始座標
    mov [ebp -24], edx  ; 描画幅
    mov [ebp -28], edi  ; 増分(基準軸:1 or -1)


    ; 基準軸を決める
    cmp ebx, edx
    jg .22F
    
    lea esi, [ebp -20]  ; Yが基準軸
    lea edi, [ebp - 8]

    jmp .22E
.22F:
    
    lea esi, [ebp - 8]  ; Xが基準軸
    lea edi, [ebp -20]
.22E:

; 基準軸 esi
; 相対軸 edi

    ; 繰り返し回数（基準軸のドット数）
    mov ecx, [esi - 4]
    cmp ecx, 0
    jnz .30E
    mov ecx, 1          ; if(基準軸の描画幅 == 0) 基準軸の描画幅 = 1
.30E:

    ; 線を描画
.50L:

%ifdef USE_SYSTEM_CALL
    mov eax, ecx
    mov ecx, [ebp - 8]
    mov edx, [ebp -20]
    mov ebx, [ebp +24]
    int 0x82            ; sys_call()
    mov ecx, eax
%else
    cdecl draw_pixel, dword [ebp - 8], \
                      dword [ebp -20], \
                      dword [ebp +24]
%endif

    ; 座標更新

    ; 基準軸の更新
    mov eax, [esi - 8]
    add [esi - 0], eax  ; 基準軸開始座標 += 基準軸増分(1 or -1)

    ; 相対軸の更新
    mov eax, [ebp - 4]  ; 相対軸の今まで描画したピクセル数
    add eax, [edi - 4]  ;           += 増分

    mov ebx, [esi - 4]  ; 基準軸の描画幅

    cmp eax, ebx        ; if(積算 < 基準軸の描画幅) goto .52E
    jl .52E
    sub eax, ebx        ; 積算 -= 描画幅

    mov ebx, [edi - 8]
    add [edi - 0], ebx  ; 相対軸の座標 += 相対軸増分
.52E:
    
    mov [ebp - 4], eax  ; 積算値を更新

    loop .50L
.50E:


    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret
