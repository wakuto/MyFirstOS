int_stop:
    sti ; 割り込みを許可

    ; EAXで示される文字列を表示
    cdecl draw_str, 25, 15, 0x060F, eax

    ; スタックのデータを文字列に変換
    mov eax, [esp + 0]
    cdecl itoa, eax, .p1, 8, 16, 0b0100

    mov eax, [esp + 4]
    cdecl itoa, eax, .p2, 8, 16, 0b0100

    mov eax, [esp + 8]
    cdecl itoa, eax, .p3, 8, 16, 0b0100

    mov eax, [esp +12]
    cdecl itoa, eax, .p4, 8, 16, 0b0100

    ; 文字列の表示
    cdecl draw_str, 25, 16, 0x0F04, .s1
    cdecl draw_str, 25, 17, 0x0F04, .s2
    cdecl draw_str, 25, 18, 0x0F04, .s3
    cdecl draw_str, 25, 19, 0x0F04, .s4

    ; 無限ループ
    jmp $

.s1 db "ESP+ 0:"
.p1 db "________ ", 0
.s2 db "   + 4:"
.p2 db "________ ", 0
.s3 db "   + 8:"
.p3 db "________ ", 0
.s4 db "   +12:"
.p4 db "________ ", 0

int_default:
    pushf       ; EFLAGS(IF==0)
    push cs
    push int_stop

    mov eax, .s0
    iret

.s0 db " <    STOP    > ", 0


; 割り込みベクタの初期化
ALIGN 4
IDTR: dw 8 * 256 - 1    ; idt_limit
      dd VECT_BASE      ; idt location

; 割り込みテーブルを初期化
init_int:
    push eax
    push ebx
    push ecx
    push edi

    ; 全ての割り込みにデフォルト処理を設定
    lea eax, [int_default]  ; 割り込み処理アドレス
    mov ebx, 0x0008_8E00    ; セグメントセレクタ
    xchg ax, bx             ; 下位ワードを交換（指定の書式に整形）

    mov ecx, 256            ; 割り込みベクタ数
    mov edi, VECT_BASE      ; 割り込みベクタテーブル

    ; メモリに書き込み
.10L:
    mov [edi + 0], ebx
    mov [edi + 4], eax
    add edi, 8
    loop .10L

    ; 割り込みディスクリプタの設定
    lidt [IDTR]

    pop edi
    pop ecx
    pop ebx
    pop eax

    ret


int_zero_div:
    pushf
    push cs
    push int_stop

    mov eax, .s0
    iret

.s0 db " <  ZERO DIV  > ", 0
