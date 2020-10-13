; マクロ
%include "../include/macro.s"   ; C言語と同等の関数呼び出し
%include "../include/define.s"  ; 各種定数の宣言

    ORG BOOT_LOAD           ; ロードアドレスをアセンブラに指示

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

    mov [BOOT + drive.no], dl    ; ブートドライブの番号(DL)を保存

    cdecl puts, .s0

    ; 残りのセクタをすべて読み込む
    mov bx, BOOT_SECT - 1           ; bx: 残りのブートセクタ数
    mov cx, BOOT_LOAD + SECT_SIZE   ; cx: 次のロードアドレス

    cdecl read_chs, BOOT, bx, cx    ; ax = read_chs(BOOT, bx, cx);

    cmp ax, bx
.10Q:
    jz .10E                 ; 読み込んだセクタ数==読み込むセクタ数
.10T:
    cdecl puts, .e0         ; 失敗
    call reboot             ; 戻ってこない
.10E:
    ; 次のステージへ
    jmp stage_2


; Data
.s0 db "Booting...", 0x0A, 0x0D, 0x00
.e0 db "Error:sector read", 0

ALIGN 2, db 0
BOOT:           ; ブートドライブ関係の情報
    istruc drive    ; struct driveを宣言
        at drive.no, dw 0       ; ドライブ番号
        at drive.cyln, dw 0     ; C:シリンダ
        at drive.head, dw 0     ; H:ヘッド
        at drive.sect, dw 2     ; S:セクタ
    iend

; モジュール
%include "../modules/real/puts.s"
%include "../modules/real/itoa.s"
%include "../modules/real/reboot.s"
%include "../modules/real/read_chs.s"

    times 510 - ($ - $$) db 0x00
    db 0x55, 0xAA




; ブート処理の第２ステージ
stage_2:
    cdecl puts, .s0
    
    jmp $       ; while(1)

; Data
.s0 db "2nd stage...", 0x0A, 0x0D, 0

; パディング(このファイルは8kBとする）
    times BOOT_SIZE - ($ - $$) db 0 ; 8kB
