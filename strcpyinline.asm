#include       macros.inc
; ***********************************************
; ***** Copy string from inline             *****
; ***** RD - pointer to destination string  *****
; ***********************************************
               proc     strcpyinline

               lda      r6             ; read byte from source string
               str      rd             ; write to destinatino
               inc      rd
               lbnz     strcpyinline   ; copy until terminator copied
               rtn                     ; then return to caller

               endp
