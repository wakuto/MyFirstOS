; mem map
; ------------+-------------------------
; 0x0000_0000 | システム領域
; ------------+-------------------------
; 0x0000_7C00 | ブートコード
; ------------+-------------------------
; 0x0000_9C00 | カーネル（一次読み込み）
; ------------+-------------------------
; 0x0010_1000 | カーネル（最終読み込み）
; ------------+-------------------------

; マクロ
%include "../include/macro.s"   ; C言語と同等の関数呼び出し
%include "../include/define.s"  ; 各種定数の宣言

    ORG BOOT_LOAD           ; ロードアドレスをアセンブラに指示

entry:
    jmp ipl      ; jump to ipl

    ; BPB(BIOS Parameter Block
    times 3 - ($ - $$) db 0x90
    db 'OEM-NAME'   ; OEM名

    dw 512          ; セクタのバイト数
    db 1            ; クラスタのセクタ数
    dw 32           ; 予約セクタ数
    db 2            ; FAT数
    dw 512          ; ルートエントリ数
    dw 0xFFF0       ; 総セクタ数16
    db 0xF8         ; メディアタイプ
    dw 256          ; FATのセクタ数
    dw 0x10         ; トラックのセクタ数
    dw 2            ; ヘッド数
    dd 0            ; 隠されたセクタ数

    dd 0            ; 総セクタ数32
    db 0x80         ; ドライブ番号
    db 0            ; 予約
    db 0x29         ; ブートフラグ
    dd 0xbeef       ; シリアルナンバー
    db 'BOOTABLE   '; ボリュームラベル
    db 'FAT16   '   ; FATタイプ


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
%include "../modules/real/memcpy.s"
%include "../modules/real/memcmp.s"

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
    ; 次のステージへ
    jmp stage_6

.s0: db "5th stage...", 0x0A, 0x0D, 0
.e0: db " Failure load kernel...", 0x0A, 0x0D, 0

; ブート処理の第６ステージ
stage_6:
    cdecl puts, .s0

    ; ユーザーからの入力待ち
.10L:
    mov ah, 0x00        ; キー入力待ち
    int 0x16
    cmp al, ' '         ; if(input != ' ') goto .10L
    jne .10L

    ; ビデオモードの設定
    mov ax, 0x0012
    int 0x10

    ; 次のステージへ
    jmp stage_7

.s0: db "6th stage...", 0x0A, 0x0D, 0x0A, 0x0D
     db " [Push SPACE key to protect mode...]", 0x0A, 0x0D, 0

; ファイル読み込み
read_file:
    push ax
    push bx
    push cx

    ; デフォルトの文字列
    cdecl memcpy, 0x7800, .s0, .s1 - .s0

    ; ルートディレクトリのセクタを読み込む
    mov bx, 32 + 256 + 256      ; BX = ディレクトリエントリの先頭セクタ
    mov cx, (512 * 32) / 512    ; CX = 512エントリ分のセクタ数
.10L:

    ; 1セクタ（16エントリ）分を読み込む
    cdecl read_lba, BOOT, bx, 1, 0x7600 ; 0x7600に読み込む
    cmp ax, 0
    je .10E

    ; ディレクトリエントリからファイル名を検索
    cdecl fat_find_file
    cmp ax, 0
    je .12E

    add ax, 32 + 256 + 256 + 32 - 2     ; セクタ位置にオフセットを加算
    cdecl read_lba, BOOT, ax, 1, 0x7800 ; 0x7800にファイルを読み込む

    jmp .10E
.12E:
    
    inc bx                      ; 次のセクタ
    loop .10L
.10E:

    pop cx
    pop bx
    pop ax

    ret

.s0: db 'File not found.', 0
.s1:

fat_find_file:
    push bx
    push cx
    push si

    ; ファイル名検索
    cld
    mov bx, 0
    mov cx, 512 / 32
    mov si, 0x7600

.10L:
    and [si + 11], byte 0x18        ; ファイルの属性チェック
    jnz .12E

    cdecl memcmp, si, .s0, 8 + 3    ; ファイル名の比較
    cmp ax, 0
    jne .12E

    mov bx, word [si + 0x1A]        ; ファイルの先頭セクタ
    jmp .10E

.12E:
    add si, 32                      ; 次のエントリ
    loop .10L
.10E:
    mov ax, bx

    pop si
    pop cx
    pop bx

    ret

.s0: db 'SPECIAL TXT', 0

; GLOBAL DESCRIPTOR TABLE
; セグメントディスクリプタの配列
ALIGN 4, db 0
GDT: dq 0x00_0_0_0_0_000000_0000   ; NULL
.cs: dq 0x00_C_F_9_A_000000_FFFF   ; CODE 4G
.ds: dq 0x00_C_F_9_2_000000_FFFF   ; DATA 4G
.gdt_end:

; セレクタ
SEL_CODE equ .cs - GDT       ; コード用セレクタ
SEL_DATA equ .ds - GDT       ; データ用セレクタ

; GDT(Global Descriptor Table)
GDTR: dw GDT.gdt_end - GDT - 1  ; ディスクリプタテーブルのリミット
      dd GDT                    ; ディスクリプタテーブルのアドレス

; IDT(Interrupt Descriptor Table) 割込み禁止のため
IDTR: dw 0          ; IDTリミット
      dd 0          ; IDTアドレス


; ブート処理の第７ステージ
stage_7:
    cli

    ; ディスクリプタテーブルをロード
    lgdt [GDTR]                 ; gdtレジスタにグローバルディスクリプタテーブルをロード
    lidt [IDTR]                 ; ldtレジスタに割り込みディスクリプタテーブルをロード

    ; プロテクトモードに移行
    mov eax, cr0
    or ax, 1                     ; cr0レジスタのpe(protect enable)をセット
    mov cr0, eax

    ; プロテクトモードに移行したのでパイプラインの命令は破棄したい
    jmp $ + 2                   ; パイプラインのクリア

    ; セグメント間ジャンプ
[BITS 32]                       ; これ移行32ビットコードを生成
    DB 0x66                     ; セグメントサイズオーバーライドプレフィックス！！！（かっこいい）
    jmp SEL_CODE:CODE_32


; 32ビットコード開始
CODE_32:        
    ; セレクタを初期化
    ; 各種セグメントレジスタにデータセグメントディスクリプタのオフセットを設定
    mov ax, SEL_DATA
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; カーネル部をコピー
    mov ecx, (KERNEL_SIZE) / 4      ; 4バイトずつコピー
    mov esi, BOOT_END               ; カーネル部の先頭アドレス(0x0000_9C00)
    mov edi, KERNEL_LOAD            ; カーネルのロード位置(0x0010_1000)
    cld                             ; DFクリア（＋方向）
    rep movsd                       ; while(--ecx) *edi++ = *esi++;

    ; カーネル処理に移行
    jmp KERNEL_LOAD                 ; カーネルの先頭にジャンプ

; リアルモードへの移行プログラム
TO_REAL_MODE:
    push ebp
    mov ebp, esp

    pusha

    cli
    
    ; 現在の設定値を保存
    mov eax, cr0
    mov [.cr0_saved], eax   ; cr0を保存
    mov [.esp_saved], esp   ; espを保存
    sidt [.idtr_save]       ; idtrを保存
    lidt [.idtr_real]       ; リアルモードの割り込み設定

    ; 16bit プロテクトモードに移行
    jmp 0x0018:.bit16       ; cs = 0x28 ; コードセグメントセレクタ
[BITS 16]
.bit16:
    mov ax, 0x0020
    mov ds, ax              ; ds = 0x20 ; データセグメントセレクタ
    mov es, ax              ; es = 0x20
    mov ss, ax              ; ss = 0x20
    ; リアルモードへ移行（ページング無効化）
    mov eax, cr0            ; PG/PEビットをクリア
    and eax, 0x7FFF_FFFE    ; cr0 &= ~(PG | PE);
    mov cr0, eax
    jmp $ + 2
    ; セグメント設定（リアルモード）
    jmp 0:.real             ; cs = 0x00
.real:
    mov ax, 0x0000          ; ds = es = ss = 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; 割り込みマスクの設定（リアルモード用）
    ; MASTER
    outp 0x20, 0x11     ; icw1 = 0x11
    outp 0x21, 0x08     ; icw2 = 0x08
    outp 0x21, 0x04     ; icw3 = 0x04
    outp 0x21, 0x01     ; icw4 = 0x01
    ; SLAVE
    outp 0xA0, 0x11     ; icw1 = 0x11
    outp 0xA1, 0x10     ; icw2 = 0x10
    outp 0xA1, 0x02     ; icw3 = 0x02
    outp 0xA1, 0x01     ; icw4 = 0x01

    outp 0x21, 0b_1011_1000 ; 割り込み有効：FDD/スレーブPIC/KBC/タイマー
    outp 0xA1, 0b_1011_1111 ; 割り込み有効：HDD
    sti

    ; ファイル読み込み
    cdecl read_file

    ; 割り込みマスクの設定（プロテクトモード用）
    cli
    ; MASTER
    outp 0x20, 0x11     ; icw1 = 0x11
    outp 0x21, 0x20     ; icw2 = 0x20
    outp 0x21, 0x04     ; icw3 = 0x04
    outp 0x21, 0x01     ; icw4 = 0x01
    ; SLAVE
    outp 0xA0, 0x11     ; icw1 = 0x11
    outp 0xA1, 0x28     ; icw2 = 0x28
    outp 0xA1, 0x02     ; icw3 = 0x02
    outp 0xA1, 0x01     ; icw4 = 0x01

    outp 0x21, 0b_1111_1000 ; 割り込み有効：スレーブPIC/KBC/タイマー
    outp 0xA1, 0b_1111_1110 ; 割り込み有効：RTC

    ; 16ビットプロテクトモードに移行
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp $ + 2

    ; 32ビットプロテクトモードに移行
    DB 0X66
[BITS 32]
    jmp 0x0008:.bit32
.bit32:
    mov ax, 0x0010
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; レジスタ設定の復帰
    mov esp, [.esp_saved]
    mov eax, [.cr0_saved]
    mov cr0, eax
    lidt [.idtr_save]

    sti

    popa

    mov esp, ebp
    pop ebp

    ret

.idtr_real:
    dw 0x3FF                ; 8 * 256 - 1   ; idt_limit
    dd 0                    ; VECT_BASE

.idtr_save:
    dw 0                    ; リミット
    dd 0                    ; ベース

.cr0_saved:
    dd 0

.esp_saved:
    dd 0

; パディング(このファイルは8kBとする）
    times BOOT_SIZE - ($ - $$) - 16 db 0    ; パディング

    dd TO_REAL_MODE                         ; リアルモード移行プログラム

    times BOOT_SIZE - ($ - $$) db 0         ; パディング
