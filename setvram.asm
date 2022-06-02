#include       macros.inc

; ***************************************************
; ***** Set virtual memory                      *****
; ***** RA - VRAM address                       *****
; ***** Returns: RA - RAM address to read/write *****
; ***************************************************
               proc     setvram
               extrn    checkvram
               extrn    vram
               push     ra             ; save address
               call     checkvram      ; be sure correct page is loaded
               pop      ra             ; recover address
               ghi      ra             ; clear high bits
               ani      001h           ; to keep address to 512 bytes
               phi      ra
               ldi      vram.0         ; add in vram address
               str      r2
               glo      ra
               add
               plo      ra
               ldi      vram.1
               str      r2
               ghi      ra
               adc
               phi      ra             ; rf now points to vram
               rtn                     ; return to caller
               endp


