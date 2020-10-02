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

    cdecl puts, .s0
    cdecl itoa, 8086, .s1, 8, 10, 0b0001    ; "    8086"
    cdecl puts, .s1
    cdecl itoa, 8086, .s1, 8, 10, 0b0011    ; "+   8086"
    cdecl puts, .s1
    cdecl itoa, -8086, .s1, 8, 10, 0b0001   ; "-   8086"
    cdecl puts, .s1
    cdecl itoa, -1, .s1, 8, 10, 0b0001      ; "-      1"
    cdecl puts, .s1
    cdecl itoa, -1, .s1, 8, 10, 0b0000      ; "   65535"
    cdecl puts, .s1
    cdecl itoa, -1, .s1, 8, 16, 0b0000      ; "    FFFF"
    cdecl puts, .s1
    cdecl itoa, 12, .s1, 8, 2, 0b0100       ; "00001100"
    cdecl puts, .s1

    jmp $       ; while(1)

.s0 db "Booting...", 0x0A, 0x0D, 0x00
.s1 db "--------", 0x0A, 0x0D, 0x00

ALIGN 2, db 0
BOOT:           ; ブートドライブ関係の情報
.DRIVE: dw 0    ; ドライブ番号

; モジュール
%include "../modules/real/puts.s"
%include "../modules/real/itoa.s"

    times 510 - ($ - $$) db 0x00
    db 0x55, 0xAA
