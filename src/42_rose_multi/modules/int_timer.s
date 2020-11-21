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

    ; タスクの切り替え(task0 -> task1 -> task2 -> task0 -> ...)
    str ax              ; 現在のタスクレジスタをロード
    cmp ax, SS_TASK_0   ; switch(ax)
    je .11L
    cmp ax, SS_TASK_1
    je .12L
    cmp ax, SS_TASK_2
    je .13L
    cmp ax, SS_TASK_3
    je .14L
    cmp ax, SS_TASK_4
    je .15L
    cmp ax, SS_TASK_5
    je .16L

    jmp SS_TASK_0:0     ; default:
    jmp .10E
.11L:                   ; case SS_TASK_0:
    jmp SS_TASK_1:0     ; タスク1に切り替え
    jmp .10E
.12L:                   ; case SS_TASK_1:
    jmp SS_TASK_2:0     ; タスク2に切り替え
    jmp .10E
.13L:                   ; case SS_TASK_2:
    jmp SS_TASK_3:0     ; タスク3に切り替え
    jmp .10E
.14L:                   ; case SS_TASK_3:
    jmp SS_TASK_4:0     ; タスク4に切り替え
    jmp .10E
.15L:                   ; case SS_TASK_4:
    jmp SS_TASK_5:0     ; タスク5に切り替え
    jmp .10E
.16L:                   ; case SS_TASK_5:
    jmp SS_TASK_6:0     ; タスク6に切り替え
    jmp .10E
.10E:

    pop es
    pop ds
    popad

    iret

ALIGN 4, db 0
TIMER_COUNT: dd 0

