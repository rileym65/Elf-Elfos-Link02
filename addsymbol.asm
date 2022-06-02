#include       macros.inc

; ************************************************
; ***** Add public symbol                    *****
; ***** RF - pointer to symbol               *****
; ***** RD - symbol value                    *****
; ***** Returns: DF=1 - Entry found          *****
; *****          DF=0 - Entry not found      *****
; *****          RA   - Value field of entry *****
; ************************************************
               proc     addsymbol

               extrn    load_ra
               extrn    store_ra
               extrn    symbols

               call7    load_ra        ; get address of symbol table
               dw       symbols
               dec      ra             ; move to end of prior entry
               glo      rd             ; write symbol value
               str      ra
               dec      ra
               ghi      rd
               str      ra
               dec      ra
               ldi      0              ; write string terminator
               str      ra
               dec      ra
               ldi      0              ; clear character counter
               plo      rc
loop1:         lda      rf             ; get byte from symbol
               lbz      isterm         ; jump if terminator encountered
               inc      rc             ; increment character count
               lbr      loop1          ; and loop until terminator found
isterm:        dec      rf             ; move back to final character of name
               dec      rf
loop2:         glo      rc             ; see if done copying string
               lbz      done           ; jump if done copying name
               ldn      rf             ; get byte from name
               str      ra             ; store to table
               dec      rf             ; decrement pointers
               dec      ra
               dec      rc             ; decrement character count
               lbr      loop2          ; loop until full name copied
done:          inc      ra             ; move pointer back to first char of name
               call7    store_ra       ; write address back to symbols
               dw       symbols
               rtn                     ; and return

               endp


