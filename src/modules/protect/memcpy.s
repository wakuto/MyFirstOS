memcpy:     ; void memcpy(src, dest, size);
    push ebp
    mov ebp, esp

    push ecx
    push esi
    push edi

    cld     ; clear direction flag
    mov edi, [ebp + 8]     ; src
    mov esi, [ebp + 12]    ; dest
    mov ecx, [ebp + 16]    ; size

    rep movsb

    pop edi
    pop esi
    pop ecx

    mov esp, ebp
    pop ebp

    ret
