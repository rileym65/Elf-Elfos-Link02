#include       macros.inc
; ************************************************
; ***** Find reference value                 *****
; ***** RF - pointer to symbol               *****
; ***** Returns: DF=1 - Entry found          *****
; *****          DF=0 - Entry not found      *****
; *****          RA   - Value field of entry *****
; *****          RB.1 - Low byte offset      *****
; ************************************************
               proc     findreference

               extrn    strcmp
               extrn    references

               mov      ra,references  ; get symbol table address
               lda      ra
               phi      rd             ; into RD
               lda      ra
               plo      rd
loop:          ldn      rd             ; get byte from table
               lbz      tableend       ; jump if at table end
               push     rf             ; save search string
               call     strcmp         ; compare entry
               pop      rf             ; recover search string
               lbdf     found          ; jump if entry found
findend:       lda      rd             ; find end
               lbnz     findend        ; loop if terminator not found
               inc      rd             ; move past value field
               inc      rd
               inc      rd             ; move past low byte offset
               inc      rd             ; move past type field
               lbr      loop           ; check next entry
tableend:      adi      0              ; signal entry not found
               rtn                     ; and return
found:         lda      rd             ; retrieve entry value
               phi      ra             ; into RA
               lda      rd
               plo      ra
               lda      rd             ; retrieve low byte offset
               plo      rb
               lda      rd             ; get reference type
               plo      re             ; keep a copy
               smi      'R'            ; is it a require?
               lbz      loop           ; not a valid reference if so
               glo      re             ; recover type
               smi      'X'            ; check for satisfied require
               lbz      loop           ; also not a valid reference
               smi      0              ; signal entry found
               rtn                     ; and return

               endp

