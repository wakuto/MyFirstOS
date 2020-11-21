task_2:
    cdecl draw_str, 63, 1, 0x07, .s0

    fild dword [.c1000]     ; st0 = [.c1000]
    fldpi           ; st0 = pi
    fidiv dword [.c180]     ; st0 /= [.c180]
    fldpi
    fadd st0, st0   ; st0 += st0
    fldz            ; st0 = 0
    ; st0   0
    ; st1   2*pi
    ; st2   pi/180
    ; st3   1000

.10L:
    fadd st0, st2   ; st0 += st2
    fprem           ; st0 %= st1
    fld st0         ; st0をコピー
    fsin            ; st0 = sin(st0)
    fmul st0, st4   ; st0 *= 1000
    fbstp [.bcd]

    mov eax, [.bcd]
    mov ebx, eax

    and eax, 0x0F0F ; 上位４ビットをマスク
    or eax, 0x3030  ; 上位４ビットに0x3に設定

    shr ebx, 4
    and ebx, 0x0F0F ; 上位４ビットをマスク
    or ebx, 0x3030  ; 上位４ビットに0x3に設定

    mov [.s2 + 0], bh   ; 1桁目
    mov [.s3 + 0], ah   ; 小数1桁目
    mov [.s3 + 1], bl   ; 小数2桁目
    mov [.s3 + 2], al   ; 小数3桁目

    mov eax, 7
    bt [.bcd + 9], eax  ; cf = .bcd+9 から7ビット目
    jc .10F

    mov [.s1 + 0], byte '+'
    jmp .10E
.10F:
    mov [.s1 + 0], byte '-'
.10E:

    cdecl draw_str, 72, 1, 0x07, .s1

    ; ウェイト
    cdecl wait_tick, 20

    jmp .10L


ALIGN 4, db 0
.c1000: dd 1000
.c180:  dd 180
.bcd: times 10 db 0x00
.s0     db "Task-2", 0
.s1:    db "-"
.s2:    db "0."
.s3:    db "000", 0
