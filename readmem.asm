#include       macros.inc

; *******************************
; ***** Read virtual memory *****
; ***** RA - VRAM address   *****
; ***** Returns: RD - value *****
; *******************************
               proc     readmem

               extrn    addressmode
               extrn    microint
               extrn    setvram
               extrn    load_d

               push     ra             ; save address
               call     setvram        ; setup for VRAM read
               mov      r7,microint
               call7    load_d         ; need to get address mode
               dw       addressmode
               smi      'L'            ; check for little endian
               lbz      little         ; jump if so
               lda      ra             ; read word from vram
               phi      rd
               ldn      ra
               plo      rd
               pop      ra             ; recover address
               rtn                     ; and return to caller
little:        lda      ra             ; read little endian value
               plo      rd
               ldn      ra
               phi      rd
               pop      ra             ; recover address
               rtn                     ; and return to caller
               endp

; word readMem(word address) {
;   word ret;
;   if (addressMode == 'L')
;     ret = memory[address] + (memory[address+1] << 8);
;   else
;     ret = memory[address+1] + (memory[address] << 8);
;   return ret;
;   }

