#include       macros.inc
#include       ../kernel.inc

; *************************************************
; ***** Show unresolved symbols               *****
; *************************************************
               proc     showunres

               extrn    cmp
               extrn    load_rf
               extrn    references

               call7    load_rf        ; get start of references
               dw       references
loop:          mov      rd,rf          ; copy entry strat to RD
               ldn      rf             ; at end of table?
               lbz      done           ; jump if so
eloop:         lda      rd             ; look for name terminator
               lbnz     eloop
               inc      rd             ; move past address
               inc      rd
               inc      rd             ; move past low byte offset
               lda      rd             ; get type
               call7    cmp            ; check low byte
               db       'L'
               lbdf     unresolved
               call7    cmp            ; check high byte
               db       'H'
               lbdf     unresolved
               call7    cmp            ; check word
               db       'W'
               lbdf     unresolved
               mov      rf,rd          ; reset pointer
               lbr      loop           ; and check next entry
unresolved:    push     rd             ; save position
               push     rf
               call     o_inmsg        ; display message
               db       'Error: Symbol ',0
               pop      rf             ; recover name
               call     o_msg          ; display it
               call     o_inmsg        ; rest of message
               db       ' not found',10,13,0
               pop      rf             ; get position of next entry
               lbr      loop           ; and process it
done:          call     o_inmsg        ; show message
               db       'Errors during link.  Aborting output',10,13,0
               rtn                     ; return to caller

               endp

