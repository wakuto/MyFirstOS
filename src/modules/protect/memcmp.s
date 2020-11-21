memcmp:     ; int memcmp(src0, src1, size);
    push ebp
    mov esp, ebp

    push ebx
    push ecx
    push edx
    push esi
    push edi

    cld
    mov edi, [ebp + 8]
    mov esi, [ebp + 12]
    mov ecx, [ebp + 16]

    repe cmpsb
    jnz .10F
    mov eax, 0
    jmp .10E

.10F:
    mov eax, -1
.10E:

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx

    mov esp, ebp
    pop ebp
    
    ret
