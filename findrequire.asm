#include       macros.inc
; ************************************************
; ***** Find require                         *****
; ***** RF - pointer to symbol               *****
; ***** Returns: DF=1 - Entry found          *****
; *****          DF=0 - Entry not found      *****
; *****          RA   - Value field of entry *****
; ************************************************
               proc     findrequire

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
               inc      rd             ; move past type field
               lbr      loop           ; check next entry
tableend:      adi      0              ; signal entry not found
               rtn                     ; and return
found:         lda      rd             ; retrieve entry value
               phi      ra             ; into RA
               lda      rd
               plo      ra
               lda      rd             ; get type
               plo      re             ; save a copy
               smi      'X'            ; check for used require
               lbz      loop           ; used requires are no longer needed
               glo      re             ; recover type
               smi      'R"            ; is it a require
               lbnz     loop           ; keep looking if not a require
               dec      rd             ; need to mark entry used
               ldi      'X'
               str      rd
               smi      0              ; signal entry found
               rtn                     ; and return

               endp

