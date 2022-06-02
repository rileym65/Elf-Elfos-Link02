#include       macros.inc
; ************************************************
; ***** Copy string to end of destination    *****
; ***** arg1 - pointer to destination string *****
; ***** arg2 - pointer to source string      *****
; ************************************************
               proc     strcat

               extrn    strcopy

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

loop:          lda      rd             ; read byte from destination
               lbnz     loop           ; loop until terminator found
               dec      rd             ; move back to terminator
               lbr      strcopy        ; and then copy source string

               endp
