int_timer:
    pushad
    push ds
    push es

    ; データ用セグメントの設定
    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    ; TICK
    inc dword [TIMER_COUNT]

    ; 割り込みフラグをクリア(EOI)
    outp 0x20, 0x20     ; マスタPIC:EOIコマンド

    ; タスクの切り替え
    str ax              ; 現在のタスクレジスタをロード
    cmp ax, SS_TASK_1   ; switch(ax)
    je .11L

    jmp SS_TASK_1:0     ; default:
    jmp .10E
.11L:                   ; case SS_TASK_1:
    jmp SS_TASK_0:0
    jmp .10E
.10E:

    pop es
    pop ds
    popad

    iret

ALIGN 4, db 0
TIMER_COUNT: dq 0

