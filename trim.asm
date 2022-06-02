#include       macros.inc
; ***********************************************
; ***** Move past any white space           *****
; ***** RF - Pointer to String              *****
; ***** Returns: RF - First non-white space *****
; ***********************************************
               proc     trim

               lda      rf             ; get byte from string
               smi      9              ; check for tab
               lbz      trim           ; check next character
               smi      23             ; check for space
               lbz      trim           ; keep looking if space
               dec      rf             ; move back to non-whitespace char
               rtn                     ; and return

               endp
