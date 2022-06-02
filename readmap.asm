#include       macros.inc

; ***************************************************
; ***** read virtual memory map                 *****
; ***** RA - VRAM address                       *****
; ***** Returns: DF=0 map address not set       *****
; *****          DF=1 map address is set        *****
; ***************************************************
               proc     readmap

               extrn    setmap

               push     ra             ; save consumed register
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
               str      r2             ; store for check
               ldn      ra             ; get byte from mask
               and                     ; combine with mask
               lbnz     set            ; jump if bit is set
               adi      0              ; clear DF
               pop      ra             ; recover consumed register
               rtn                     ; and return
set:           smi      0              ; set DF
               pop      ra             ; recover consumed register
               rtn                     ; and return

               endp


