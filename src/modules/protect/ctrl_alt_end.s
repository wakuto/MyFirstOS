ctrl_alt_end:       ; int ctrl_alt_end(key)
    push ebp
    mov ebp, esp


; key: 入力されたキーコード
; 戻り値: ctrl+alt+endキーの同時押下が検出されたとき、0以外の値
    
    ; キー状態保存
    mov eax, [ebp + 8]      ; eax = key
    btr eax, 7              ; cf = eax & 0b0000_0000_1000_0000
    jc .10F                 ; if(cf == 1) goto .10F
    bts [.key_state], eax   ; セット
    jmp .10E
.10F:
    btc [.key_state], eax   ; クリア
.10E:

    ; キー押下判定
    mov eax, 0x1D           ; ctrl
    bt [.key_state], eax    ; if(.key_state[ctrl] == 0) goto .20E
    jnc .20E

    mov eax, 0x38           ; alt
    bt [.key_state], eax    ; if(.key_state[alt] == 0) goto .20E
    jnc .20E

    mov eax, 0x4F           ; end
    bt [.key_state], eax    ; if(.key_state[end] == 0) goto .20E
    jnc .20E

    mov eax, -1             ; 3つのキーが押されていたら0以外

.20E:
    sar eax, 8              ; 先頭1ビットで埋める

    mov esp, ebp
    pop ebp

    ret

.key_state: times 32 db 0
