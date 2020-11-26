draw_time:  ; void draw_time(col, row, color, time);
; time 時刻データ
    push ebp
    mov ebp, esp

    push eax
    push ebx
    
    mov eax, [ebp +20]  ; 時:分:秒
    cmp eax, [.last]
    je .10E
    mov [.last], eax

    movzx ebx, al       ; 秒だけ
    cdecl itoa, ebx, .sec, 2, 16, 0b0100

    mov bl, ah          ; 分だけ
    cdecl itoa, ebx, .min, 2, 16, 0b0100
    
    shr eax, 16         ; 時だけ
    cdecl itoa, eax, .hour, 2, 16, 0b0100

    cdecl draw_str, dword [ebp + 8], dword [ebp +12], dword [ebp +16], .hour ; 文字の表示

.10E:

    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret

ALIGN 2, db 0
.hour: db "ZZ:"
.min:  db "ZZ:"
.sec:  db "ZZ", 0
.last: dq 0
