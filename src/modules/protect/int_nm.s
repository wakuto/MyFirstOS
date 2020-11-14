get_tss_base:
; EBX: TSSセレクタ
    ; EAX = TSS base address
    mov eax, [GDT + ebx + 2]
    shl eax, 8
    mov al, [GDT + ebx + 7]
    ror eax, 8

    ret

save_fpu_context:
    fnsave [eax + 104]
    mov [eax + 104 + 108], dword 1

    ret

load_fpu_context:
    cmp [eax + 104 + 108], dword 0
    jne .10F    ; if(saved != 0) goto .10F
    fninit      ; FPU初期化
    jmp .10E
.10F:
    frstor [eax + 104]  ; FPUコンテキストを復帰
.10E:
    ret

int_nm:
    pusha
    push ds
    push es

    mov ax, DS_KERNEL
    mov ds, ax
    mov es, ax

    ; タスクスイッチフラグをクリア
    clts    ; CR0.TS = 0

    ; 前回・今回FPUを使用するタスク
    mov edi, [.last_tss]; edi = 前回FPUを使用したタスクのTSS
    str esi             ; esi = 今回FPUを使用するタスクのTSS（trレジスタ）
    and esi, ~0x0007    ; 特権レベルはいらないのでマスク

    ; 初回利用チェック
    cmp edi, 0          ; if(前回のタスク==0) goto .10F
    je .10F

    cmp esi, edi        ; if(前回のタスク==今回のタスク) goto .12E
    je .12E

    cli

    ; 前回のFPUコンテキストを保存
    mov ebx, edi
    call get_tss_base       ; eax get_tss_base(ebx);
    call save_fpu_context   ; void save_fpu_context(eax);

    ; 今回のFPUコンテキストを復帰
    mov ebx, esi
    call get_tss_base       ; eax get_tss_base(ebx);
    call load_fpu_context   ; void load_fpu_context(eax);

    sti
.12E:
    jmp .10E
.10F:
    cli

    ; 今回のFPUコンテキストを復帰
    mov ebx, esi
    call get_tss_base       ; eax get_tss_base(ebx);
    call load_fpu_context   ; void load_fpu_context(eax);

    sti
.10E:

    mov [.last_tss], esi

    pop es
    pop ds
    popa

    iret

ALIGN 4, db 0
.last_tss: dd 0
