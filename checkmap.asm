#include       macros.inc
#include       ../kernel.inc

; ***************************************************
; ***** Check that correct MAP block is loaded  *****
; ***** for given address                       *****
; ***** RA - VRAM address                       *****
; ***************************************************
               proc     checkmap

               extrn    mapfildes
               extrn    microint

               mov      rd,mapfildes+2  ; point to MAP fildes + 2
               ldn      rd             ; get high word pos byte
               dec      rd             ; move to beginning of fildes
               dec      rd
               ani      0feh           ; 512 byte boundary
               str      r2             ; store for comparison
               ghi      ra             ; get high of address
               ani      01eh           ; 8192 byte boundary
               sm                      ; check against file position
               lbnz     needload       ; jump if not correct sector
               rtn                     ; return if no load needed
needload:      push     rc
               ghi      ra             ; need to set seek address
               ani      0feh           ; on 512-byte boundary
               phi      r7
               ldi      0              ; rest of position is cleared
               plo      r7
               phi      r8
               plo      r8
               plo      rc             ; seek from beginning
               phi      rc
               call     o_seek         ; perform file seek
               pop      rc             ; recover consumed registers
               mov      r7,microint
               rtn                     ; return to caller

               endp
