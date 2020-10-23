    SECT_SIZE equ (512)                     ; セクタサイズ

    BOOT_SIZE equ (1024 * 8)                ; ブートコードサイズ
    KERNEL_SIZE equ (1024 * 8)              ; カーネルサイズ

    KERNEL_LOAD equ 0x0010_1000             ; カーネルのロード位置

    E820_RECORD_SIZE equ 20

    BOOT_LOAD equ 0x7C00                    ; ブートプログラムのロード位置
    BOOT_END equ (BOOT_LOAD + BOOT_SIZE)    ; ブートコードの終了位置

    BOOT_SECT equ (BOOT_SIZE / SECT_SIZE)   ; ブートコードのセクタ数
    KERNEL_SECT equ (KERNEL_SIZE / SECT_SIZE)   ; カーネルのセクタ数
