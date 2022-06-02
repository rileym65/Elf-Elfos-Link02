#include       macros.inc

; ********************************
; ***** WRite virtual memory *****
; ***** RA - VRAM address    *****
; *****  D - value           *****
; ********************************
               proc     writememb

               extrn    setvram

               plo      re             ; save value during pushes
               push     ra             ; save consumed registers
               push     rf
               push     r7
               glo      re
               stxd                    ; save value
               call     setvram        ; setup VRAM for write
               glo      rd             ; move to fildes flags byts
               adi      8
               plo      rd
               ghi      rd
               adci     0
               phi      rd
               ldn      rd             ; retrieve flags
               ori      011h           ; mark sector as modified
               str      rd             ; put it back
               irx                     ; recover value to write
               ldx
               str      ra             ; write to VRAM
               pop      r7
               pop      rf             ; recover consumed registers
               pop      ra
               rtn                     ; then return to caller

               endp

