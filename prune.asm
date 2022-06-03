#include       macros.inc

; **************************************
; ***** Remove resolved references *****
; **************************************
               proc     prune

               extrn    load_rf
               extrn    references
               extrn    referencesend
               extrn    store_rd

               call7    load_rf        ; get references table start
               dw       references
               mov      rd,rf          ; copy to RD
loop:          ldn      rf             ; see if end of table
               lbz      tableend       ; jump if so
               push     rf             ; keep a copy of entry start
eloop:         lda      rf             ; find terminator for entry name
               lbnz     eloop          ; loop until terminator found
               inc      rf             ; move past address
               inc      rf
               inc      rf             ; move past low byte offset
               lda      rf             ; get type
               smi      '*'            ; check if cleared
               lbz      empty          ; do not copy this entry
               pop      rf             ; recover entry start
copyloop:      lda      rf             ; read from entry name
               str      rd             ; store into destination
               inc      rd
               lbnz     copyloop       ; loop until terminator copied
               lda      rf             ; copy next 4 bytes
               str      rd
               inc      rd
               lda      rf
               str      rd
               inc      rd
               lda      rf
               str      rd
               inc      rd
               lda      rf
               str      rd
               inc      rd
               lbr      loop           ; and process next entry
empty:         irx                     ; remove address from stack
               irx
               lbr      loop           ; and process next entry
tableend:      ldi      0              ; place table terminator at dest
               str      rd
               call7    store_rd       ; write new table end
               dw       referencesend
               rtn                     ; and return to caller

               endp


