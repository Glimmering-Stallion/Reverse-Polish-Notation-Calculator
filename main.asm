; main.asm

EXIT    equ 60
READ    equ 0
WRITE   equ 1
STDIN   equ 0
STDOUT  equ 1
BUFLEN  equ 256

        extern printf, scanf
        extern add_c, sub, mul, div
        extern char_to_int

section .data

        Input   db      "Enter an expression in reverse polish notation: ", 0 
        len1:   equ     $-Input

        Output db       "Result of %s is: %d", 10, 0

section .bss

        exp     resb    BUFLEN             ; input expression to be stored
        num:    resd    1                  ; storage for integer values
        stack   resb    100                ; stack

section .text

        global  main

main:   

input:
        ; prompt the user for expression input
      	mov     rax, WRITE
      	mov     rdi, STDOUT
      	mov     rsi, Input
      	mov     rdx, len1
      	syscall
      
        ; store the expression input
      	mov     rax, READ
      	mov     rdi, STDIN
      	mov     r10, exp
        mov     rsi, r10
      	mov     rdx, BUFLEN
      	syscall

set_up_loop:
        ; set up loop to iterate over each character in string from expression input
        push    rbp                        ; set up stack
        mov     r10, exp                   ; move memory address of exp into r10
        mov     rcx, 0                     ; set rcx to zero for loop counter

loop:
        mov     al, [r10 + rcx]            ; get current character
        cmp     al, 10                     ; check if current character is 10 (ASCII for newline), the end of string
        je      end_loop                   ; if so, the end of string is reached, exit loop
    
        ; check if current character is an integer or not
        cmp     al, '0'                    ; check if current character is greater than or equal to '0'
        jl      not_int                    ; if not, check if it's a space or operator
        cmp     al, '9'                    ; check if current character is less than or equal to '9'
        jg      not_int                    ; if not, check if it's a space or operator

        ; convert character to integer
        push    ax                         ; save al register value
        call    char_to_int                ; call char_to_int external function
        add     rsp, 2                     ; remove character from stack

append_cond:
        ; if num is empty, skip the multiplication
        mov     edx, 0                     ; set edx to zero for empty append
        cmp     dword [num], 0             ; check if num is empty or not
        je      append                     ; skip multiplication

        ; if num is not empty, shift existing digits in num to the left and append new digit to least significant digit
        mov     edx, [num]                 ; move value of num into edx
        imul    edx, 10                    ; multiply value in edx by 10, shifting it left by one decimal place
        jmp     append

append:
        ; store or append integer to existing number
        add     rdx, rax                   ; append value in al (stored in rax) to least significant digit of existing integer value stored in edx (stored in rdx)
        mov     [num], rdx                 ; store new value of edx into memory address pointed to by num
        jmp     next_char                  ; process next character in string from expression input

push:
        ; because the most recent character read in was a space, the stored integers in num is pushed onto stack
        push    qword [num]                ; push value of num onto stack
        mov     qword [num], 0             ; clear contents stored in num to store the next digit or potential sequence of digits
        jmp     next_char                  ; process next character in string from expression input

not_int:
        ; check if current character is a space
        cmp     al, ' '
        je      push                       ; if so, jump to push

        ; check if current character is an operator
        cmp     al, '+'                    ; check if current character is '+'
        je      handle_addition            ; if so, jump to addition handler
        cmp     al, '-'                    ; check if current character is '-'
        je      handle_subtraction         ; if so, jump to subtraction handler
        cmp     al, '*'                    ; check if current character is '*'
        je      handle_multiplication      ; if so, jump to multiplication handler
        cmp     al, '/'                    ; check if current character is '/'
        je      handle_division            ; if so, jump to division handler

next_char:
        inc     rcx                        ; increment loop counter
        jmp     loop

handle_addition:
        ; operand extraction from stack
        pop     rax                        ; pop operand 2 from stack into rax
        mov     rbx, qword [rsp]           ; move operand 1 at next stack position into rbx
        add     rsp, 8                     ; increment stack pointer by 8 bytes (64 bit value was popped from stack)

        ; arithmetic calculation
        mov     edi, ebx                   ; pass arguments (operand 1) for add
        mov     esi, eax                   ; pass arguments (operand 2) for add
        call    add_c                      ; addition function (coded in add_c.c)
        jmp     append_cond

handle_subtraction:
        ; operand extraction from stack
        pop     rax                        ; pop operand 2 from stack into rax
        mov     rbx, qword [rsp]           ; move operand 1 at next stack position into rbx
        add     rsp, 8                     ; increment stack pointer by 8 bytes (64 bit value was popped from stack)

        ; arithmetic calculation
        mov     edi, ebx                   ; pass arguments (operand 1) for sub
        mov     esi, eax                   ; pass arguments (operand 2) for sub
        call    sub                        ; subtraction function (coded in funcs.asm)
        jmp     append_cond

handle_multiplication:
        ; operand extraction from stack
        pop     rax                        ; pop operand 2 from stack into rax
        mov     rbx, qword [rsp]           ; move operand 1 at next stack position into rbx
        add     rsp, 8                     ; increment stack pointer by 8 bytes (64 bit value was popped from stack)

        ; arithmetic calculation
        mov     edi, ebx                   ; pass arguments (operand 1) for mul
        mov     esi, eax                   ; pass arguments (operand 2) for mul
        call    mul                        ; multiplication function (coded in funcs.asm)
        jmp     append_cond

handle_division:
        ; operand extraction from stack
        pop     rax                        ; pop operand 2 from stack into rax
        mov     rbx, qword [rsp]           ; move operand 1 at next stack position into rbx
        add     rsp, 8                     ; increment stack pointer by 8 bytes (64 bit value was popped from stack)

        ; arithmetic calculation
        mov     edi, ebx                   ; pass arguments (operand 1) for div
        mov     esi, eax                   ; pass arguments (operand 2) for div
        call    div                        ; division function (coded in funcs.asm)
        jmp     append_cond

end_loop:

output:
        ; display final resultant value from the evaluated expression
        mov     byte [r10 + rcx], 0        ; replace newline from end of expression with 0 (ASCII for null terminator), for output formatting
        mov     rdi, Output
        mov     rsi, r10
      	mov     rdx, [num]
      	mov     rax, 0
      	call    printf

exit:
        pop     rbp                        ; restore stack
        mov     rax, 0
        ret                                ; end main

; end main.asm