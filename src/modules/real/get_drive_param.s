get_drive_param:    ; int get_drive_param(drive);
; drive: drive構造体のアドレス
;        no 対象となるドライブ番号（BIOSから渡された起動ドライブ）
; 戻り値: 成功（0以外） 失敗（0）

    push bp
    mov bp, sp

    push bx
    push cx
    push es
    push si
    push di

    ; 処理開始
    mov si, [bp + 4]        ; si = バッファ

    mov ax, 0               ; Disk Base Table Pointerの初期化
    mov es, ax              ; es = di = 0
    mov di, ax

    mov ah, 0x08            ; ah = ドライブパラメータの取得
    mov dl, [si + drive.no] ; dl = ドライブ番号
    int 0x13

.10Q:
    jc .10F
.10T:       ; 成功
    mov al, cl
    and ax, 0x3f    ; alの下位6ビット セクタ数のみ有効

    shr cl, 6       ; cl = シリンダ上位2ビット
                    ; ch = シリンダ下位8ビット
    ror cx, 8       ; chとclを交換、cx = シリンダ
    inc cx          ; 1始まりに変換

    movzx bx, dh    ; bx = ヘッド数 ゼロ拡張
    inc bx          ; 1はじまりに変換

    ; cx = シリンダ
    ; bx = ヘッド
    ; ax = セクタ
    mov [si + drive.cyln], cx
    mov [si + drive.head], bx
    mov [si + drive.sect], ax

    jmp .10E

.10F:       ; 失敗
    mov ax, 0
    
.10E:
    
    pop di
    pop si
    pop es
    pop cx
    pop bx

    mov sp, bp
    pop bp

    ret
