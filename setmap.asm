#include       macros.inc

; ***************************************************
; ***** Set virtual memory map                  *****
; ***** RA - VRAM address                       *****
; ***** Returns: RA - RAM address to read/write *****
; ***************************************************
               proc     setmap

               extrn    checkmap
               extrn    map

               ldi      3              ; need to divide address by 8
               plo      re
loop:          ghi      ra             ; divide by 2
               shr
               phi      ra
               glo      ra
               shrc
               plo      ra
               dec      re             ; decrement count
               glo      re             ; see if done
               lbnz     loop           ; loop until divided by 8
               push     ra             ; save address
               call     checkmap       ; be sure correct page is loaded
               pop      ra             ; recover address
               ghi      ra             ; clear high bits
               ani      001h           ; keep lower 512 bytes
               phi      ra
               ldi      map.0          ; add in map address
               str      r2
               glo      ra
               add
               plo      ra
               ldi      map.1
               str      r2
               ghi      ra
               adc
               phi      ra             ; rf now points to map addres
               rtn                     ; return to caller

               endp


