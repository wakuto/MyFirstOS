    BOOT_LOAD   equ 0x7c00  ; ブートプログラムのロード位置
    ORG BOOT_LOAD           ; ロードアドレスをアセンブラに指示

; マクロ
%include "../include/macro.s"   ; C言語と同等の関数呼び出し

entry:
    jmp ipl      ; jump to ipl

    ; BPB(BIOS Parameter Block
    times 90 - ($ - $$) db 0x90


    ; IPL(Initial Program Loader)
ipl:
    cli         ; clear interrupu flag 割込み禁止

    mov ax, 0x0000
    mov dx, ax
    mov es, ax
    mov ss, ax
    mov sp, BOOT_LOAD
    
    sti         ; set interrupt flag 割り込み許可

    mov [BOOT.DRIVE], dl    ; ブートドライブの番号(DL)を保存

    cdecl putc, word 'X'
    cdecl putc, word 'Y'
    cdecl putc, word 'Z'

    jmp $       ; while(1)

ALIGN 2, db 0
BOOT:           ; ブートドライブ関係の情報
.DRIVE: dw 0    ; ドライブ番号

; モジュール
%include "../modules/real/putc.s"

    times 510 - ($ - $$) db 0x00
    db 0x55, 0xAA
