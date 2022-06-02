#include       macros.inc
; ****************************************************
; ***** Convert RA to 4 hex digits               *****
; ***** R9 - Where to put                        *****
; ***** Returns: R9   - incremented              *****
; ****************************************************
               proc     outhex4

               extrn    outhex2

               ghi      ra             ; output high byte
               call     outhex2
               glo      ra             ; output low byte
               call     outhex2
               rtn                     ; then return to caller

               endp
