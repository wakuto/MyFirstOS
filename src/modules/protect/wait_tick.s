wait_tick:
    push ebp
    mov ebp, esp

    push eax
    push ecx

    ; ウェイト
    mov ecx, [ebp + 8]      ; ECX = ウェイト回数
    mov eax, [TIMER_COUNT]  ; EAX = TIMER

.10L:
    cmp [TIMER_COUNT], eax  ; for(i=0; i < ecx; i++) while(TIMER == eax);
    je .10L
    inc eax
    loop .10L

    pop ecx
    pop eax

    mov esp, ebp
    pop ebp

    ret
