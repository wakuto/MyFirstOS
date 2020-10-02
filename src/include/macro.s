; C言語と同等の関数呼び出し
%macro cdecl 1-*.nolist ; 可変引数, リスト出力の抑止

    %rep %0 - 1         ; 引数の数-1回
        push %{-1:-1}   ; 一番最後の引数
        %rotate -1      ; 一番最後の引数を先頭に移動
    %endrep
    %rotate -1      ; 回転をもとに戻す

    call %1         ; 第１引数を呼び出し

    %if 1 < %0
        add sp, (__BITS__ >> 3) * (%0 - 1)  ; cpuのbyte数(bit数/8) * 引数の数-1
    %endif
%endmacro
