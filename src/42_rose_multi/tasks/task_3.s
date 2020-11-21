task_3:
    mov ebp, esp

    push dword 0    ; x0    x座標原点
    push dword 0    ; y0    y座標原点
    push dword 0    ; x     x座標描画
    push dword 0    ; y     y座標描画
    push dword 0    ; r     角度

    ; 初期化
    ;mov esi, DRAW_PARAM ; esi = 描画パラメータ
    mov esi, 0x0010_7000

    ; タイトル表示
    mov eax, [esi + rose.x0]
    mov ebx, [esi + rose.y0]

    shr eax, 3                      ; EAX = EAX /  8 x座標を文字位置に変換
    shr ebx, 4                      ; EBX = EBX / 16 y座標を文字位置に変換
    dec ebx                         ; 1文字分上に移動
    mov ecx, [esi + rose.color_s]   ; 文字色
    lea edx, [esi + rose.title]     ; タイトル

    cdecl draw_str, eax, ebx, ecx, edx

    ; X軸の中点
    mov eax, [esi + rose.x0]
    mov ebx, [esi + rose.x1]
    sub ebx, eax            ; ebx = x0 - x1
    shr ebx, 1              ; ebx /= 1
    add ebx, eax            ; ebx += x0
    mov [ebp - 4], ebx      ; x0 = 原点

    ; Y軸の中点
    mov eax, [esi + rose.y0]
    mov ebx, [esi + rose.y1]
    sub ebx, eax            ; ebx = y0 - y1
    shr ebx, 1              ; ebx /= 1
    add ebx, eax            ; ebx += y0
    mov [ebp - 8], ebx      ; y0 = 原点

    ; X軸の描画
    mov eax, [esi + rose.x0]
    mov ebx, [ebp - 8]
    mov ecx, [esi + rose.x1]

    cdecl draw_line, eax, ebx, ecx, ebx, dword [esi + rose.color_x]

    ; Y軸の描画
    mov eax, [esi + rose.y0]
    mov ebx, [ebp - 4]
    mov ecx, [esi + rose.y1]

    cdecl draw_line, ebx, eax, ebx, ecx, dword [esi + rose.color_y]

    ; 枠の描画
    mov eax, [esi + rose.x0]
    mov ebx, [esi + rose.y0]
    mov ecx, [esi + rose.x1]
    mov edx, [esi + rose.y1]

    cdecl draw_rect, eax, ebx, ecx, edx, dword [esi + rose.color_z]

    ; 振幅をX軸の約95%とする
    mov eax, [esi + rose.x1]
    sub eax, [esi + rose.x0]
    shr eax, 1                  ; eax = 原点から右端の長さ
    mov ebx, eax
    shr ebx, 4
    sub eax, ebx

    ; FPUの初期化（バラ曲線の初期化）
    cdecl fpu_rose_init\
            , eax\
            , dword [esi + rose.n]\
            , dword [esi + rose.d]

    ; メインループ
.10L:
    ; 座標計算
    lea ebx, [ebp -12]  ; EBX = &x;
    lea ecx, [ebp -16]  ; ECX = &y;
    mov eax, [ebp -20]  ; EAX = r;

    cdecl fpu_rose_update\
            , ebx\
            , ecx\
            , eax

    ; 角度更新(r = r % 36000)
    mov edx, 0
    inc eax
    mov ebx, 360 * 100
    div ebx             ; EDX = EDX:EAX % EBX
    mov [ebp -20], edx

    ; ドット描画
    mov ecx, [ebp -12]  ; x座標
    mov edx, [ebp -16]  ; y座標

    add ecx, [ebp - 4]  ; x座標原点
    add edx, [ebp - 8]  ; y座標原点

    mov ebx, [esi + rose.color_f]   ; 表示色
    int 0x82            ; sys_call_82(表示色, X, Y)

    ; ウェイト
    cdecl wait_tick, 2

    ; ドット描画(消去)
    mov ebx, [esi + rose.color_b]   ; 背景色
    int 0x82           ; sys_call_82(表示色, X, Y)

    jmp .10L


ALIGN 4, db 0
DRAW_PARAM:
.t3:
    istruc rose
        at rose.x0,         dd  32
        at rose.y0,         dd  32
        at rose.x1,         dd 208
        at rose.y1,         dd 208

        at rose.n,          dd 2
        at rose.d,          dd 1

        at rose.color_x,    dd 0x007
        at rose.color_y,    dd 0x007
        at rose.color_z,    dd 0x00F
        at rose.color_s,    dd 0x30F
        at rose.color_f,    dd 0x00F
        at rose.color_b,    dd 0x003

        at rose.title,      db "Task-3", 0
    iend
.t4:
    istruc rose
        at rose.x0,         dd 248
        at rose.y0,         dd  32
        at rose.x1,         dd 424
        at rose.y1,         dd 208

        at rose.n,          dd 3
        at rose.d,          dd 1

        at rose.color_x,    dd 0x007
        at rose.color_y,    dd 0x007
        at rose.color_z,    dd 0x00F
        at rose.color_s,    dd 0x30F
        at rose.color_f,    dd 0x00F
        at rose.color_b,    dd 0x003

        at rose.title,      db "Task-4", 0
    iend
.t5:
    istruc rose
        at rose.x0,         dd  32
        at rose.y0,         dd 272
        at rose.x1,         dd 208
        at rose.y1,         dd 448

        at rose.n,          dd 2
        at rose.d,          dd 6

        at rose.color_x,    dd 0x007
        at rose.color_y,    dd 0x007
        at rose.color_z,    dd 0x00F
        at rose.color_s,    dd 0x30F
        at rose.color_f,    dd 0x00F
        at rose.color_b,    dd 0x003

        at rose.title,      db "Task-5", 0
    iend
.t6:
    istruc rose
        at rose.x0,         dd 248
        at rose.y0,         dd 272
        at rose.x1,         dd 424
        at rose.y1,         dd 448

        at rose.n,          dd 4
        at rose.d,          dd 6

        at rose.color_x,    dd 0x007
        at rose.color_y,    dd 0x007
        at rose.color_z,    dd 0x00F
        at rose.color_s,    dd 0x30F
        at rose.color_f,    dd 0x00F
        at rose.color_b,    dd 0x003

        at rose.title,      db "Task-6", 0
    iend

fpu_rose_init:
    push ebp
    mov ebp, esp

    push dword 180

    fldpi
    fidiv dword [ebp - 4]   ; 180
    fild  dword [ebp +12]   ; n
    fidiv dword [ebp +16]   ; d
    fild  dword [ebp + 8]   ; A

    mov esp, ebp
    pop ebp

    ret

fpu_rose_update:
; px: 計算したX座標を格納するアドレス
; py: 計算したY座標を格納するアドレス
; t:  角度

    push ebp
    mov ebp, esp

    push eax
    push ebx

    mov eax, [ebp +  8] ; eax = px
    mov ebx, [ebp + 12] ; ebx = py

    fild dword [ebp +16]    ; t
    fmul st0, st3           ; st0 = t * r = θ
    fld st0

    fsincos                 ; st0 = cos(st0)
                            ; st1 = sin(st0)
    
    fxch st2                ; st0 <-> st2
    fmul st0, st4           ; st0 = kθ
    fsin                    ; st0 = sin(kθ)
    fmul st0, st3           ; st0 = Asin(kθ)

    ; st0 = Asin(kθ)
    ; st1 = sin(θ)
    ; st2 = cos(θ)
    ; st3 = A
    ; st4 = k
    ; st5 = r

    fxch st2                ; cosをst0に
    fmul st0, st2           ; st0 *= Asin(kθ)
    fistp dword [eax]       ; st0を[eax]にpop

    fmulp st1, st0          ; st1 *= st0; st0をpop
    fchs                    ; st0 * (-1)
    fistp dword [ebx]       ; st0を[ebx]にpop

    pop ebx
    pop eax
    mov esp, ebp
    pop ebp

    ret
