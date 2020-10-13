read_chs:           ; int read_chs(drive, sect, dst);
; drive: drive構造体のアドレス
; sect:  読み出しセクタ数
; dst:   読み出し先アドレス
; 戻り値:読み込んだセクタ数
    push bp
    mov bp, sp
    push 3          ; リトライ回数
    push 0          ; 読み込みセクタ数

    push bx
    push cx
    push dx
    push es
    push si

    ; 処理開始
    mov si, [bp + 4]    ; drive パラメータバッファ
    
    ; cxレジスタの設定
    mov ch, [si + drive.cyln + 0]
    mov cl, [si + drive.cyln + 1]
    shl cl, 6
    or cl, [si + drive.sect]

    ; セクタ読み込み
    mov dh, [si + drive.head];ヘッド番号
    mov dl, [si + drive.no] ; ドライブ番号
    mov ax, 0x0000          ; 初期化
    mov es, ax              ; セグメント
    mov bx, [bp + 8]        ; コピー先
.10L:

    mov ah, 0x02        ; セクタ読み込み
    mov al, [bp + 6]    ; 読み込みセクタ数
    int 0x13
    jnc .11E            ; if(success) goto .11E

    mov al, 0           ; failed, 読み込んだセクタ数=0
    jmp .10E
.11E:
    
    cmp al, 0
    jne .10E            ; if(読み込んだセクタ != 0) goto .10E
    
    mov ax, 0
    dec word [bp - 2]   ; retry--
    jnz .10L            ; if(retry != 0) goto .10L
.10E:
    mov ah, 0           ; ステータス情報を破棄

    pop si
    pop es
    pop dx
    pop cx
    pop bx

    mov sp, bp
    pop bp

    ret
