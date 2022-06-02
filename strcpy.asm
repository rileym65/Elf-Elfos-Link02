#include       macros.inc
; ***********************************************
; ***** Copy string                         *****
; ***** arg1 - destination address          *****
; ***** arg2 - source address               *****
; ***********************************************
               proc     strcpy

               push     rf             ; save consumed registers
               push     rd
               lda      r6             ; retrieve destination address
               phi      rd
               lda      r6
               plo      rd
               lda      r6             ; retrieve source address
               phi      rf
               lda      r6
               plo      rf

strcopy:       lda      rf             ; read byte from source string
               str      rd             ; write to destinatino
               inc      rd
               lbnz     strcopy        ; copy until terminator copied

               pop      rd             ; recover consumed registers
               pop      rf
               rtn                     ; then return to caller

               public   strcopy

               endp
