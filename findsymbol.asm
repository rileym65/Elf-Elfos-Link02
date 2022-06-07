#include       macros.inc
; ************************************************
; ***** Find symbol value                    *****
; ***** RF - pointer to symbol               *****
; ***** Returns: DF=1 - Entry found          *****
; *****          DF=0 - Entry not found      *****
; *****          RA   - Value field of entry *****
; ************************************************
               proc     findsymbol
               extrn    strcmp
               extrn    symbols
               mov      ra,symbols     ; get symbol table address
               lda      ra
               phi      rd             ; into RD
               lda      ra
               plo      rd
loop:          ldn      rd             ; get byte from table
               lbz      tableend       ; jump if at table end
               push     rf             ; save search string
               push     rd             ; save table entry
               call     strcmp         ; compare entry
               pop      rd
               pop      rf             ; recover search string
               lbdf     found          ; jump if entry found
findend:       lda      rd             ; find end
               lbnz     findend        ; loop if terminator not found
               inc      rd             ; move past value field
               inc      rd
               lbr      loop           ; check next entry
tableend:      adi      0              ; signal entry not found
               rtn                     ; and return
found:         lda      rd             ; move past name
               lbnz     found
               lda      rd             ; retrieve entry value
               phi      ra             ; into RA
               lda      rd
               plo      ra
               smi      0              ; signal entry found
               rtn                     ; and return
               endp

; int findSymbol(char* name) {
;   int i;
;   for (i=0; i<numSymbols; i++)
;     if (strcmp(symbols[i],name) == 0) return i;
;   return -1;
;   }

