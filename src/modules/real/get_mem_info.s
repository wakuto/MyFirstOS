get_mem_info:   ; void get_mem_info(void)
; ACPIテーブルが含まれるメモリ領域をグローバルラベルACPI_DATAに保存する
    push eax
    push ebx
    push ecx
    push edx
    push si
    push di
    push bp

    mov bp, 0
    mov ebx, 0

    cdecl puts, .s4
    cdecl puts, .s0
.10L:
    mov eax, 0x0000E820
    mov ecx, E820_RECORD_SIZE
    mov edx, 'PAMS'
    mov di, .b0
    int 0x15

    cmp eax, 'PAMS'             ; BIOSが対応しているかの確認
    je .12E
    jmp .10E
.12E:   ; 対応してる
    jnc .14E
    jmp .10E
.14E:   ; 成功
    ; 1レコード分のメモリ情報を表示
    cdecl put_mem_info, di

    ; ACPI dataのアドレスを取得
    mov eax, [di + 16]          ; データタイプを参照
    cmp eax, 3                  ; data type = 3（ACPI)
    jne .15E

    mov eax, [di + 0]           ; レコードのベースアドレス
    mov [ACPI_DATA.adr], eax

    mov eax, [di + 8]           ; Length
    mov [ACPI_DATA.len], eax

.15E:
    
    cmp ebx, 0                  ; 最終データだったら.16Eへ
    jz .16E

    inc bp
    and bp, 0x07                ; 表示ライン数が0x07を超えてなければ.16Eへ
    jnz .16E

    ; 中断メッセージ
    cdecl puts, .s2
    mov ah, 0x10
    int 0x16

    cdecl puts, .s3

.16E:

    cmp ebx, 0                  ; 最終データじゃなかったらループ
    jne .10L

.10E:
    cdecl puts, .s1

    pop bp
    pop di
    pop si
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret


ALIGN 4, db 0
.b0: times E820_RECORD_SIZE db 0
.s0: db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1: db " _________________ _________________ ________", 0x0A, 0x0D, 0
.s2: db " <more...>", 0
.s3: db 0x0D, "          ", 0x0D, 0
.s4: db " E820 Memory Map:", 0x0A, 0x0D, 0



put_mem_info:   ; void put_mem_info(adr);
; adr メモリ情報を参照するアドレス
    
    push bp
    mov bp, sp

    push bx
    push si

    mov si, [bp + 4]

    ; レコード全20ビットを文字に変換し出力
    ; Base(64bit)
    cdecl itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100
    cdecl itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
    cdecl itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100
    cdecl itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100

    ; Length(64bit)
    cdecl itoa, word [si + 14], .p4 + 0, 4, 16, 0b0100
    cdecl itoa, word [si + 12], .p4 + 4, 4, 16, 0b0100
    cdecl itoa, word [si + 10], .p5 + 0, 4, 16, 0b0100
    cdecl itoa, word [si +  8], .p5 + 4, 4, 16, 0b0100

    ; Type(32bit)
    cdecl itoa, word [si + 18], .p6 + 0, 4, 16, 0b0100
    cdecl itoa, word [si + 16], .p6 + 4, 4, 16, 0b0100

    cdecl puts, .s1

    ; タイプの情報を文字列で表示
    mov bx, [si + 16]
    and bx, 0x07            ; bxの下位3ビットがタイプ
    shl bx, 1
    add bx, .t0
    cdecl puts, word [bx]   ; .t0からのオフセット

    pop si
    pop bx
    
    mov sp, bp
    pop bp

    ret

.s1: db " "
.p2: db "ZZZZZZZZ_"
.p3: db "ZZZZZZZZ "
.p4: db "ZZZZZZZZ_"
.p5: db "ZZZZZZZZ "
.p6: db "ZZZZZZZZ", 0

.s4: db " (Unknown)", 0x0A, 0x0D, 0
.s5: db " (usable)", 0x0A, 0x0D, 0
.s6: db " (reserved)", 0x0A, 0x0D, 0
.s7: db " (ACPI data)", 0x0A, 0x0D, 0
.s8: db " (ACPI NVS)", 0x0A, 0x0D, 0
.s9: db " (bad memory)", 0x0A, 0x0D, 0

.t0: dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4
