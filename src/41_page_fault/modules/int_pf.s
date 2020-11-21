int_pf:
    xchg bx, bx
    push ebp
    mov ebp, esp

    pusha
    push ds
    push es

    ; データ用セグメントセレクタの設定
    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    ; 例外を生成したアドレスの確認
    mov eax, cr2            ; ページフォルトの際アクセスしようとしたアドレス
    and eax, ~0x0FFF        ; 4KB 以内のアクセス
    cmp eax, 0x0010_7000    ; if(アクセスしようとしたアドレス!=0x0010_7000) goto .10F
    jne .10F

    mov [0x00106000 + 0x107 * 4], dword 0x00107007  ; ページの有効化
    cdecl memcpy, 0x0010_7000, DRAW_PARAM, rose_size; 描画パラメータのコピー
    jmp .10E

.10F:
    ; スタックの調整
    add esp, 4      ; pop es
    add esp, 4      ; pop ds
    popa
    pop ebp

    ; タスク終了処理
    pushf           ; EFLAGS
    push cs         ; CS
    push int_stop   ; スタック表示処理

    mov eax, .s0    ; 割り込み種別
    iret

.10E:

    pop es
    pop ds
    popa

    mov esp, ebp
    pop ebp

    add esp, 4  ; エラーコードの破棄
    iret

.s0 db " < PAGE FAULT > ", 0
