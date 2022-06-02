#include       macros.inc

; *************************************************
; ***** Return count of unresolved references *****
; ***** Returns: RC - Count                   *****
; *************************************************
               proc     refcount

               extrn    cmp
               extrn    load_rf
               extrn    references

               ldi      0              ; set count to zero
               phi      rc
               plo      rc
               call7    load_rf        ; get start of references
               dw       references
loop:          ldn      rf             ; check for end of table
               lbz      done           ; jump if end reached
eloop:         lda      rf             ; move past name
               lbnz     eloop          ; loop until terminator found
               inc      rf             ; move past address
               inc      rf
               lda      rf             ; get type
               call7    cmp            ; check for require
               db       'R'
               lbdf     loop           ; do not count requires
               call7    cmp            ; check for used require
               db       'X'
               lbdf     loop           ; do not count used requires
               call7    cmp            ; check for resolved reference
               db       '*'
               lbdf     loop           ; jump if resolved reference
               inc      rc             ; increment unresolved count
               lbr      loop           ; and check next entry

done:          rtn                     ; return to caller

               endp

