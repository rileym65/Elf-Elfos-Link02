#include       macros.inc
#include       ../kernel.inc

; *********************************************
; ***** Show public symbols               *****
; *********************************************
               proc     dispsymbols

               extrn    buffer
               extrn    cmp
               extrn    crlf
               extrn    load_rf
               extrn    outhex4
               extrn    symbols

               call7    load_rf        ; get start of public symbols
               dw       symbols
loop:          ldn      rf             ; check for end of table
               lbz      done
               ldi      -20            ; clear character count
               plo      rc
eloop:         lda      rf             ; get byte from name
               lbz      edone          ; jump if done with name
               call     o_type         ; otherwise display character
               inc      rc             ; increment count
               lbr      eloop          ; and loop back for more
edone:         glo      rc             ; enough characters output
               shl
               lbnf     egood          ; jump if so
               ldi      ' '            ; otherwise display a space
               call     o_type
               inc      rc             ; increment count
               lbr      edone          ; loop until 20 characters output
egood:         lda      rf             ; get symbol value
               phi      ra
               lda      rf
               plo      ra
               push     rf             ; save position
               mov      r9,buffer      ; point to buffer
               call     outhex4        ; convert to ascii
               mov      rf,buffer      ; and display it
               call     o_msg
               call     crlf
               pop      rf             ; recover buffer position
               lbr      loop           ; loop for next symbol
done:          rtn                     ; return to caller

               endp

