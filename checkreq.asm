#include       macros.inc

; ****************************************************
; ***** Check if a .requires already exists      *****
; ***** RF - Pointer to requires                 *****
; ***** Returns: DF=1 - Requires exists          *****
; *****          DF=0 - does not exist           *****
; ****************************************************
               proc     checkreq

               extrn    load_rd
               extrn    references
               extrn    strcmp

               call7    load_rd        ; get address of references table
               dw       references
loop:          ldn      rd             ; see if end of table
               lbz      tableend       ; jump if so
               push     rf             ; save positions
               push     rd
               call     strcmp         ; see if current entry matches
               pop      rd             ; recover positions
               pop      rf
eloop:         lda      rd             ; need to find end of name
               lbnz     eloop          ; loop until terminator found
               inc      rd             ; move past address
               inc      rd
               lbnf     nomatch        ; jump if entry does not match
               lda      rd             ; retrieve type
               plo      re             ; save a copy
               smi      'R'            ; is it R
               lbz      found          ; requires entry found
               glo      re             ; recover type
               smi      'X'            ; check for spent requires
               lbnz     loop           ; check next entry if not requires
found:         smi      0              ; signal entry was found
               rtn                     ; and return to caller
nomatch:       inc      rd             ; move past type
               lbr      loop           ; and check next entry
tableend:      adi      0              ; signal requires does not exist
               rtn                     ; and return to caller

               endp
