rtc_get_time:   ; int rtc_get_time(dst);
; dst: 保存先アドレス
; 戻り値: 成功(0以外)、失敗(0)
    push ebp
    mov ebp, esp

    push eax
    push ebx

    mov al, 0x0A    ; レジスタA
    out 0x70, al
    in al, 0x71
    test al, 0x80   ; if(!更新中) goto .10F
    je .10F
    mov eax, 1      ; 更新中は失敗
    jmp .10E
.10F:

    mov al, 0x04    ; 時
    out 0x70, al    ; レジスタ設定
    in al, 0x71     ; 時刻読み込み

    shl eax, 8      ; alをahに退避

    mov al, 0x02    ; 分
    out 0x70, al    ; レジスタ設定
    in al, 0x71     ; 時刻読み込み

    shl eax, 8      ; alをahに退避

    mov al, 0x00    ; 秒
    out 0x70, al    ; レジスタ設定
    in al, 0x71     ; 時刻読み込み

    and eax, 0x00_FF_FF_FF  ; 時:分:秒のみ有効

    mov ebx, [ebp + 8]
    mov [ebx], eax  ; [dst] = 時刻

    mov eax, 0
.10E:

    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret
