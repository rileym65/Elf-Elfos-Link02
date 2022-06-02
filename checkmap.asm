#include       macros.inc
#include       ../kernel.inc

; ***************************************************
; ***** Check that correct MAP block is loaded  *****
; ***** for given address                       *****
; ***** RA - VRAM address                       *****
; ***************************************************
               proc     checkmap

               extrn    mapfildes

               mov      rd,mapfildes+2  ; point to MAP fildes + 2
               ldn      rd             ; get high word pos byte
               ani      0e0h           ; 8192 byte boundary
               str      r2             ; store for comparison
               ghi      ra             ; get high of address
               ani      0e0h           ; 8192 byte boundary
               sm                      ; check against file position
               lbnz     needload       ; jump if not correct sector
               rtn                     ; return if no load needed
needload:      push     r7             ; save consumed registers
               push     rc
               ghi      ra             ; need to set seek address
               ani      0e0h           ; on 8192-byte boundary
               phi      r7
               ldi      0              ; rest of position is cleared
               plo      r7
               phi      r8
               plo      r8
               plo      rc             ; seek from beginning
               phi      rc
               dec      rd             ; move to beginning of fildes
               dec      rd
               call     o_seek         ; perform file seek
               pop      rc             ; recover consumed registers
               pop      r7
               rtn                     ; return to caller

               endp
