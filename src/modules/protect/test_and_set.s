test_and_set:
    push ebp
    mov ebp, esp

    push eax
    push ebx

    ; テストアンドセット
    mov eax, 0
    mov ebx, [ebp + 8]

    ; bts命令 第1引数の第2引数ビットを読み込んだあと、そのビットを1にセットする。
    ; lockプレフィックス 読み込みと書き込みを分割しない
.10L:
    lock bts [ebx], eax ; cf = 書き込む前のビットの状態
    jnc .10E

.12L:
    bt [ebx], eax       ; cf = 現在のビットの状態
    jc .12L
    
    jmp .10L
.10E:
    
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret
