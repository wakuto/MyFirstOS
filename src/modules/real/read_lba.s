read_lba:   ; int read_lba(drive, lba, sect, dst);
; drive drive構造体のアドレス（ドライブパラメータが格納されている）
; lba LBA
; sect 読み出しセクタ数
; dst 読み出し先アドレス
; 戻り値 読み込んだセクタ数

    push bp
    mov bp, sp

    push ax
    push si

    mov si, [bp + 4]        ; si = ドライブ情報

    ; LBA->CHS変換
    mov ax, [bp + 6]
    cdecl lba_chs, si, .chs, ax ; lba_chs(drive, .chs, AX);

    ; ドライブ番号のコピー
    mov al, [si + drive.no]
    mov [.chs + drive.no], al   ; ドライブ番号保存

    ; セクタの読み込み
    cdecl read_chs, .chs, word [bp + 8], word [bp + 10] ; ax = read_chs(.chs, セクタ数 , ofs);

    pop si

    mov sp, bp
    pop bp

    ret

.chs: times drive_size  db 0        ; 読み込みセクタに関する情報
