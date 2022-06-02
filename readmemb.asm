#include       macros.inc

; *******************************
; ***** Read virtual memory *****
; ***** RA - VRAM address   *****
; ***** Returns: D - value  *****
; *******************************
               proc     readmemb

               extrn    setvram

               push     ra             ; save address
               call     setvram        ; setup for VRAM read
               lda      ra             ; retrieve byte
               pop      ra             ; recover address
               rtn                     ; and return to caller

               endp


