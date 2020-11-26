power_off:
    push ebp
    mov ebp, esp

    pusha

    ; ページングを無効化
    mov eax, cr0
    and eax, 0x7FFF_FFFF    ; CR0 &= &PG
    mov cr0, eax
    jmp $ + 2

    ; ACPIデータの確認
    mov eax, [0x7C00 + 512 + 4] ; ACPI.addr
    mov ebx, [0x7C00 + 512 + 8] ; ACPI.len
    cmp eax, 0
    je .10E     ; if(ACPI.addr == NULL) goto .10E
    
    ; RSDTテーブルの検索
    cdecl acpi_find, eax, ebx, 'RSDT'   ; eax = acpi_find('RSDT')
    cmp eax, 0
    je .10E     ; if(RSDT is not found) goto .10E

    ; FACPテーブルの検索
    cdecl find_rsdt_entry, eax, 'FACP'  ; eax = find_rsdt_entry('FACP')
    cmp eax, 0
    je .10E     ; if(FACP is not found) goto .10E

    mov ebx, [eax + 40] ; DSDT(差分システムディスクリプタテーブル)アドレスの取得
    cmp ebx, 0          ; if(DSDT == NULL) goto .10E
    je .10E

    ; ACPIレジスタの保存
    mov ecx, [eax + 64]     ; ACPIレジスタの取得
    mov [PM1a_CNT_BLK], ecx ; PM1a_CNT_BLK = FACP.PM1a_CNT_BLK

    mov ecx, [eax + 68]     ; ACPIレジスタの取得
    mov [PM1b_CNT_BLK], ecx ; PM1b_CNT_BLK = FACP.PM1b_CNT_BLK


    ; S5名前空間の検索
    mov ecx, [ebx + 4]      ; ECX = DSDT.Length
    sub ecx, 36             ; テーブルヘッダ分減算
    add ebx, 36             ; テーブルヘッダ分加算
    cdecl acpi_find, ebx, ecx, '_S5_'   ; eax = acpi_find('_S5_');
    cmp eax, 0
    je .10E                 ; if(_S5_ addr == NULL) goto .10E


    ; パッケージデータの取得
    add eax, 4                      ; eax = 先頭の要素
    cdecl acpi_package_value, eax   ; eax = パッケージデータ
    mov [S5_PACKAGE], eax           ; S5_PACKAGE = eax

.10E:

    ; ページングを有効化
    mov eax, cr0
    or eax, (1 << 31)       ; CR0 |= PG
    mov cr0, eax
    jmp $ + 2

    ; ACPIレジスタの取得
    mov edx, [PM1a_CNT_BLK]
    cmp edx, 0
    je .20E     ; if(PM1a_CNT_BLK == NULL) goto .20E

    ; カウントダウンの表示
    cdecl draw_str, 38, 14, 0x020F, .s3
    cdecl wait_tick, 100
    cdecl draw_str, 38, 14, 0x020F, .s2
    cdecl wait_tick, 100
    cdecl draw_str, 38, 14, 0x020F, .s1
    cdecl wait_tick, 100

    ; PM1a_CNT_BLKの設定
    movzx ax, [S5_PACKAGE.0]    ; PM1a_CNT_BLK
    shl ax, 10      ; ax = SLP_TYPx
    or ax, 1 << 13  ; ax |= SLP_EN
    out dx, ax      ; out(PM1a_CNT_BLK, ax)

.20E:

    ; 電断待ち
    cdecl wait_tick, 100    ; 100msウェイト

    ; 電断失敗メッセージ
    cdecl draw_str, 38, 14, 0x020F, .s4

    popa

    mov esp, ebp
    pop ebp

    ret

ALIGN 4, db 0
.s0: db "Power off...   ", 0
.s1: db " 1", 0
.s2: db " 2", 0
.s3: db " 3", 0
.s4: db "NG", 0
PM1a_CNT_BLK:   dd 0
PM1b_CNT_BLK:   dd 0
S5_PACKAGE:
.0: db 0
.1: db 0
.2: db 0
.3: db 0
