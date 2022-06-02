#include       macros.inc

; ***************************************************
; ***** Set virtual memory map                  *****
; ***** RA - VRAM address                       *****
; ***************************************************
               proc     writemap

               extrn    setmap

               push     ra             ; save address register
               glo      ra             ; need to save low byte
               ani      07h            ; need only low 3 bits
               stxd
               call     setmap         ; set RA to correct memory address
               ldi      1              ; setup mask
               plo      re
               irx                     ; recover bit position
               ldx
loop:          lbz      done           ; jump if done setting mask
               smi      1              ; subtract 1
               str      r2             ; save it
               glo      re             ; shift mask
               shl
               plo      re
               ldn      r2             ; recover count
               lbr      loop           ; loop until zero
done:          glo      re             ; get mask
               str      r2             ; store for combination
               ldn      ra             ; get byte from mask
               or                      ; combine with mask
               str      ra             ; and write back to map
               glo      rd             ; move to fildes flags byts
               adi      8
               plo      rd
               ghi      rd
               adci     0
               phi      rd
               ldn      rd             ; retrieve flags
               ori      011h           ; mark sector as modified
               str      rd             ; put it back
               pop      ra             ; recover address
               rtn                     ; return to caller

               endp


