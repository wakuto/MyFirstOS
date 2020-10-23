lba_chs:    ; lba_chs(drive, drive_chs, lba);
; drive drive構造体のアドレス（ドライブパラメータが格納されている）
; drv_chs drive構造体のアドレス（変換後のシリンダ番号、ヘッド番号、セクタ番号を保存する）
; lba LBA
; 戻り値 成功(0以外) 失敗(0)
    push bp
    mov bp, sp

    push bx
    push dx
    push si
    push di


    mov si, [bp + 4]            ; driveバッファ
    mov di, [bp + 6]            ; drv_chsバッファ

    mov al, [si + drive.head]   ; al = 最大ヘッド数
    mul byte [si + drive.sect]  ; ax = 最大ヘッド数 * 最大セクタ数
    mov bx, ax                  ; bx = シリンダあたりのセクタ数

    mov dx, 0                   ; dx = lba(上位2byte)
    mov ax, [bp + 8]            ; ax = lba(下位2byte)
    div bx                      ; dx = dx:ax % bx   あまり
                                ; ax = dx:ax / bx   シリンダ番号
    mov [di + drive.cyln], ax   ; drv_chs.cyln = シリンダ番号

    mov ax, dx                  ; ax = あまり
    div byte [si + drive.sect]  ; ah = ax % 最大セクタ数    // セクタ番号
                                ; al = ax / 最大セクタ数    // シリンダ番号

    movzx dx, ah                ; dx = セクタ番号
    inc dx                      ; １始まりにする

    mov ah, 0x00                ; ax = ヘッド位置(0x00:al)

    mov [di + drive.head], ax   ; drv_chs.head = ヘッド番号
    mov [di + drive.sect], dx   ; drv_chs.sect = セクタ番号

    pop di
    pop si
    pop dx
    pop bx

    mov sp, bp
    pop bp

    ret
