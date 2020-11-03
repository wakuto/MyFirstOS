int_rtc:
    pusha   ; ax, bx, cx, dx, sp, bp, si, diをまとめてpush
    push ds
    push es

    ; データ用セグメントセレクタの設定
    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    ; RTCから時刻を取得
    cdecl rtc_get_time, RTC_TIME

    ; RTCの割り込み要因を取得
    outp 0x70, 0x0C ; RTCのレジスタCを選択
    in al, 0x71     ; RTCからデータを取得

    ; 割り込みフラグをクリア(EOI)
    mov al, 0x20
    out 0xA0, al    ; スレーブ
    out 0x20, al    ; マスタ

    pop es
    pop ds
    popa

    iret        ; 割り込み処理の終了

rtc_int_en:
    push ebp
    mov ebp, esp
    push eax

    ; 割り込み許可設定
    outp 0x70, 0x0B ; RTCのレジスタBを選択

    in al, 0x71     ; RTCからデータを取得
    or al, [ebp + 8]; 指定したビットをセット

    out 0x71, al    ; RTCのレジスタBに書き込み

    pop eax

    mov esp, ebp
    pop ebp

    ret
