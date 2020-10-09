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
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BOOT_LOAD
    
    sti         ; set interrupt flag 割り込み許可

    mov [BOOT.DRIVE], dl    ; ブートドライブの番号(DL)を保存

    cdecl puts, .s0

    ; 次の512バイトを読み込む
    mov ah, 0x02            ; セクタ読み出し
    mov al, 0x01            ; 読み込みセクタ数
    mov cx, 0x0002          ; シリンダ/セクタ
    mov dh, 0x00            ; ヘッド位置
    mov dl, [BOOT.DRIVE]    ; ドライブ番号
    mov bx, 0x7C00 + 512    ; 読み込み先オフセット
    int 0x13

.10Q:
    jnc .10E
.10T:
    cdecl puts, .e0
    cdecl reboot            ; 戻ってこない
.10E:
    jmp stage_2


; Data
.s0 db "Booting...", 0x0A, 0x0D, 0x00
.e0 db "Error:sector read", 0

ALIGN 2, db 0
BOOT:           ; ブートドライブ関係の情報
.DRIVE: dw 0    ; ドライブ番号

; モジュール
%include "../modules/real/puts.s"
%include "../modules/real/itoa.s"
%include "../modules/real/reboot.s"

    times 510 - ($ - $$) db 0x00
    db 0x55, 0xAA



; ブート処理の第２ステージ
stage_2:
    cdecl puts, .s0
    jmp $       ; while(1)

; Data
.s0 db "2nd stage...", 0x0A, 0x0D, 0

; パディング(このファイルは8kBとする）
    times (1024 * 8) -($ - $$) db 0 ; 8kB
