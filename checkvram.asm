#include       macros.inc
#include       ../kernel.inc

; ****************************************************
; ***** Check that correct VRAM block is loaded  *****
; ***** for given address                        *****
; ***** RA - VRAM address                        *****
; ****************************************************
               proc     checkvram

               extrn    vramfildes

               mov      rd,vramfildes+2  ; point to VRAM fildes + 2
               ldn      rd             ; get high word pos byte
               ani      0feh           ; 512 byte boundary
               str      r2             ; store for comparison
               ghi      ra             ; get high of address
               ani      0feh           ; 512 byte boundary
               sm                      ; check against file position
               lbnz     needload       ; jump if not correct sector
               rtn                     ; return if no load needed
needload:      ghi      ra             ; need to set seek address
               ani      0feh           ; on sector boundary
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

               endp
