init_page:
    pusha

    cdecl page_set_4m, CR3_BASE     ; ページ変換テーブルの作成 タスク3用
    cdecl page_set_4m, CR3_TASK_4   ; ページ変換テーブルの作成 タスク4用
    cdecl page_set_4m, CR3_TASK_5   ; ページ変換テーブルの作成 タスク5用
    cdecl page_set_4m, CR3_TASK_6   ; ページ変換テーブルの作成 タスク5用
    mov [0x0010_6000 + 0x107 * 4], dword 0   ; 0x0010_7000をページ不在に設定

    ; アドレス変換設定
    mov [0x0020_1000 + 0x107 * 4], dword PARAM_TASK_4 + 7   ; タスク4用
    mov [0x0020_3000 + 0x107 * 4], dword PARAM_TASK_5 + 7   ; タスク5用
    mov [0x0020_5000 + 0x107 * 4], dword PARAM_TASK_6 + 7   ; タスク6用

    ; 描画パラメータの設定
    cdecl memcpy, PARAM_TASK_4, DRAW_PARAM.t4, rose_size    ; タスク4用
    cdecl memcpy, PARAM_TASK_5, DRAW_PARAM.t5, rose_size    ; タスク5用
    cdecl memcpy, PARAM_TASK_6, DRAW_PARAM.t6, rose_size    ; タスク6用

    popa

    ret


page_set_4m:
    push ebp
    mov ebp, esp

    pusha

    ; ページディレクトリの作成
    cld                     ; dfをクリア (+方向)
    mov edi, [ebp + 8]      ; EDI = ページディレクトリの先頭
    mov eax, 0x00000000     ; EAX = 0   P = 0
    mov ecx, 1024           ; count = 1024
    rep stosd               ; while(ecx--) *(edi++) = eax;

    ; 先頭のエントリを設定
    mov eax, edi            ; ページディレクトリの直後
    and eax, ~0x0000_0FFF   ; 物理アドレスの指定
    or eax, 7               ; U/S R/W Pの許可
    mov [edi - (1024 * 4)], eax ; 先頭のエントリを設定

    ; ページングテーブルの設定(リニア)
    mov eax, 0x00000007     ; 物理アドレスの指定とU/S R/W Pの許可
    mov ecx, 1024           ; count = 1024
.10L:                       ; do {
    stosd                   ;   *(edi++) = eax
    add eax, 0x00001000     ;   eax += 0x1000
    loop .10L               ; } while(--count)

    popa

    mov esp, ebp
    pop ebp

    ret
