int_en_timer0:
    push eax

    outp 0x43, 0b_00_11_010_0   ; カウンタ0 下位/上位で書き込み, モード2, バイナリ
    outp 0x40, 0x9C             ; 下位バイト
    outp 0x40, 0x2E             ; 上位バイト

    pop eax

    ret
