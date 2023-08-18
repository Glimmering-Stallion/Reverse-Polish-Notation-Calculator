;funcs.asm

section .text
global sub, mul, div, char_to_int

; add function already implemented

sub:    ; function sub(int x, int y)
        mov     rax, rdi         ; get argument x
        sub     rax, rsi         ; subtract argument y, x - y result in rax
        ret

mul:    ; function mul(int x, int y)
        mov     rax, rdi         ; move x into rax
        mul     rsi              ; multiply rax by y
        ret

div:     ; function div(int x, int y)
        mov    rax, rdi          ; move x into rax
        xor    rdx, rdx          ; zero out rdx to prevent floating point exception
        div    rsi               ; divide rax by y
        ret

char_to_int:   ; function char_to_int(char c)
        ; converts a character in al to an integer in ax
        sub    al, '0'           ; convert ASCII digit to integer
        mov    ah, 0             ; clear upper 8 bits of ax
        movsx  ax, al            ; sign-extend al to ax
        ret