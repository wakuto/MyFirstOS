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
%include "../modules/real/reboot.s"
%include "../modules/real/read_chs.s"

    times 510 - ($ - $$) db 0x00
    db 0x55, 0xAA

; リアルモード時に取得した情報
FONT:       ; フォントデータ
.seg: dw 0
.off: dw 0
ACPI_DATA:  ; ACPI data
.adr: dd 0  ; ACPI data address
.len: dd 0  ; ACPI data length

; モジュール（512バイトに入らなかった分）
%include "../modules/real/itoa.s"
%include "../modules/real/get_drive_param.s"
%include "../modules/real/get_font_adr.s"
%include "../modules/real/get_mem_info.s"
%include "../modules/real/kbc.s"
%include "../modules/real/read_lba.s"
%include "../modules/real/lba_chs.s"

; ブート処理の第２ステージ
stage_2:
    cdecl puts, .s0

    ; ドライブ情報を取得
    cdecl get_drive_param, BOOT
    cmp ax, 0
.10Q:
    jne .10E
.10T:   ; 失敗
    cdecl puts, .e0
    call reboot

.10E:   ; 成功
    ; ドライブ情報を表示
    mov ax, [BOOT + drive.no]
    cdecl itoa, ax, .p1, 2, 16, 0b0100
    mov ax, [BOOT + drive.cyln]
    cdecl itoa, ax, .p2, 4, 16, 0b0100
    mov ax, [BOOT + drive.head]
    cdecl itoa, ax, .p3, 2, 16, 0b0100
    mov ax, [BOOT + drive.sect]
    cdecl itoa, ax, .p4, 2, 16, 0b0100
    cdecl puts, .s1
    
    ; 次のステージへ
    jmp stage_3rd

.s1 db " Drive:0x"
.p1 db "  , C:0x"
.p2 db "    , H:0x"
.p3 db "  , S:0x"
.p4 db "  ", 0x0A, 0x0D, 0

.e0 db "Can't get drive parameter.", 0

; Data
.s0 db "2nd stage...", 0x0A, 0x0D, 0

; ブート処理の第３ステージ
stage_3rd:
    ; 文字列を表示
    cdecl puts, .s0

    cdecl get_font_adr, FONT    ; BIOSのフォントアドレスを取得

    ; フォントアドレスの表示
    cdecl itoa, word [FONT.seg], .p1, 4, 16, 0b0100
    cdecl itoa, word [FONT.off], .p2, 4, 16, 0b0100
    cdecl puts, .s1

    ; メモリ情報の取得と表示
    cdecl get_mem_info              ; get_mem_info()

    mov eax, [ACPI_DATA.adr]
    cmp eax, 0                      ; if(eax == 0) goto .10E
    je .10E

    cdecl itoa, ax, .p4, 4, 16, 0b0100  ; 下位１６ビットを変換
    shr eax, 16
    cdecl itoa, ax, .p3, 4, 16, 0b0100  ; 上位１６ビットを変換

    cdecl puts, .s2
.10E:
    
    ; 次のステージへ
    jmp stage_4


; データ
.s0 db "3rd stage...", 0x0A, 0x0D, 0
.s1 db " Font Address="
.p1 db "ZZZZ:"
.p2 db "ZZZZ", 0x0A, 0x0D, 0
    db 0x0A, 0x0D, 0

.s2 db " ACPI data="
.p3 db "ZZZZ"
.p4 db "ZZZZ", 0x0A, 0x0D, 0


; ブート処理の第４ステージ
stage_4:
    cdecl puts, .s0

    ; A20ゲート有効化
    cli                         ; 割込み禁止
    cdecl KBC_Cmd_Write, 0xAD   ; キーボード無効化
    cdecl KBC_Cmd_Write, 0xD0   ; 出力ポート読み出しコマンド
    cdecl KBC_Data_Read, .key   ; 出力ポートデータ

    mov bl, [.key]
    or bl, 0x02         ; A20ゲート有効化

    cdecl KBC_Cmd_Write, 0xD1   ; 出力ポート書き込みコマンド
    cdecl KBC_Data_Write, bx    ; 出力ポートデータ

    cdecl KBC_Cmd_Write, 0xAE   ; キーボード有効化
    sti                         ; 割り込み許可

    cdecl puts, .s1

    ; キーボードLEDのテスト
    cdecl puts, .s2
    
    mov bx, 0
.10L: 
    mov ah, 0x00    ; キー入力
    int 0x16        ; al = keyinput()

    ; 1～3以外のキーを押すとループ終了
    cmp al, '1'
    jb .10E

    cmp al, '3'
    ja .10E

    ; 0x31～0x33を 0～2に変換
    mov cl, al
    dec cl
    and cl, 0x03
    mov ax, 0x0001  ; マスクを0～2ビットシフト
    shl ax, cl
    xor bx, ax      ; 押されたらLEDの状態を反転

    ; LEDコマンドの送信
    cli             ; 割込み禁止

    cdecl KBC_Cmd_Write, 0xAD   ; キーボード無効化

    cdecl KBC_Data_Write, 0xED  ; LEDコマンド
    cdecl KBC_Data_Read, .key   ; Ack受信

    cmp [.key], byte 0xFA       ; Ack受け取れなかったらgoto .11F
    jne .11F

    cdecl KBC_Data_Write, bx    ; 受け取れたらLEDデータ出力
    jmp .11E
.11F:   ; Ack失敗
    cdecl itoa, word [.key], .e1, 2, 16, 0b0100
    cdecl puts, .e0
.11E:   ; Ack成功
    cdecl KBC_Cmd_Write, 0xAE   ; キーボード有効化

    sti             ; 割り込み許可

    jmp .10L
.10E:
    cdecl puts, .s3

    ; 次のステージへ移行
    jmp stage_5


.s0: db "4th stage...", 0x0A, 0x0D, 0
.s1: db " A20 Gate Enabled.", 0x0A, 0x0D, 0
.s2: db " Keyboard LED Test...", 0
.s3: db " (done)", 0x0A, 0x0D, 0
.e0: db "["
.e1: db "ZZ]", 0

.key: dw 0


; ブート処理の第５ステージ
stage_5:
    cdecl puts, .s0

    ; カーネルを読み込む
    cdecl read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END
    cmp ax, KERNEL_SECT     
.10Q:
    jz .10E                 ; if(読み込みセクタ数 == 読み込んだセクタ数) goto .10E
.10T:
    cdecl puts, .e0
    call reboot
.10E:
    ; 処理の終了
    jmp $

.s0: db "5th stage...", 0x0A, 0x0D, 0
.e0: db " Failure load kernel...", 0x0A, 0x0D, 0

; パディング(このファイルは8kBとする）
    times BOOT_SIZE - ($ - $$) db 0 ; 8kB
