#include       macros.inc

; *******************************
; ***** Read virtual memory *****
; ***** RA - VRAM address   *****
; ***** Returns: RD - value *****
; *******************************
               proc     readmem

               extrn    addressmode
               extrn    microint
;               extrn    setvram
               extrn    readmemb
               extrn    load_d

               push     ra             ; save address
               call7    load_d         ; need to get address mode
               dw       addressmode
               smi      'L'            ; check for little endian
               lbz      little         ; jump if so
               call     readmemb       ; read high byte
               stxd                    ; save for now
               inc      ra             ; point to next address
               call     readmemb       ; read low byte
               plo      rd             ; set return value
               irx
               ldx
               phi      rd
done:          mov      r7,microint    ; reset R7
               pop      ra             ; recover address
               rtn                     ; and return
little:        call     readmemb       ; read low byte
               stxd                    ; save it
               inc      ra             ; point to next address
               call     readmemb       ; read high byte
               phi      rd             ; set return value
               irx
               ldx
               plo      rd
               lbr      done           ; all done



;               push     ra             ; save address
;               call     setvram        ; setup for VRAM read
;               mov      r7,microint
;               call7    load_d         ; need to get address mode
;               dw       addressmode
;               smi      'L'            ; check for little endian
;               lbz      little         ; jump if so
;               lda      ra             ; read word from vram
;               phi      rd
;               ldn      ra
;               plo      rd
;               pop      ra             ; recover address
;               rtn                     ; and return to caller
;little:        lda      ra             ; read little endian value
;               plo      rd
;               ldn      ra
;               phi      rd
;               pop      ra             ; recover address
;               rtn                     ; and return to caller
               endp

; word readMem(word address) {
;   word ret;
;   if (addressMode == 'L')
;     ret = memory[address] + (memory[address+1] << 8);
;   else
;     ret = memory[address+1] + (memory[address] << 8);
;   return ret;
;   }

