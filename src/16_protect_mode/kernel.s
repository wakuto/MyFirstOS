%include "../include/define.s"
%include "../include/macro.s"

    ORG KERNEL_LOAD

[BITS 32]   ; 32bitコードを生成

; エントリポイント
kernel:
    ; 処理の終了
    jmp $

;パディング
    times KERNEL_SIZE - ($ - $$) db 0

