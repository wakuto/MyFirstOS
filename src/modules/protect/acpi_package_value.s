acpi_package_value:
    push ebp
    mov ebp, esp

    push esi

    ; 引数取得
    mov esi, [ebp + 8]      ; パッケージへのアドレス

    ; パケットのヘッダをスキップ
    inc esi     ; skip 'PackageOp'
    inc esi     ; skip 'PkgLength'
    inc esi     ; skip 'NumElements'

    ; 2バイトのみを取得
    mov al, [esi]
    cmp al, 0x0B
    je .C0B
    cmp al, 0x0C
    je .C0C
    cmp al, 0x0E
    je .C0E
    jmp .C0A

.C0B:                   ; case 0x0B:    'WordPrefix'
.C0C:                   ; case 0x0C:    'DWordPrefix'
.C0E:                   ; case 0x0D:    'QWordPrefix'
    mov al, [esi + 1]
    mov ah, [esi + 2]
    jmp .10E

.C0A:                   ; default:      'BytePrefix' | 'ConstObj'
    ; 最初の1バイト
    cmp al, 0x0A
    jne .11E
    mov al, [esi + 1]
    inc esi
.11E:
    ; 次の1バイト
    inc esi

    mov ah, [esi]
    cmp ah, 0x0A
    jne .12E
    mov ah, [esi + 1]
.12E:
.10E:

    pop esi

    mov esp, ebp
    pop ebp

    ret
