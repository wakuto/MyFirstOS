call_gate:
    push ebp
    mov ebp, esp

    pusha
    push ds
    push es

    ; データ用セグメントの設定
    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    ; 文字を表示
    mov eax, dword [ebp +12]    ; x
    mov ebx, dword [ebp +16]    ; y
    mov ecx, dword [ebp +20]    ; color
    mov edx, dword [ebp +24]    ; 文字
    cdecl draw_str, eax, ebx, ecx, edx  ; draw_str()

    pop es
    pop ds
    popa

    mov esp, ebp
    pop ebp

    ; コードセグメントセレクタの復帰と終了
    retf 4 * 4  ; 4byte * 4引数分スタックの調整
