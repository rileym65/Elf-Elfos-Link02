#include       macros.inc

; ********************************
; ***** WRite virtual memory *****
; ***** RA - VRAM address    *****
; ***** RD - value           *****
; ********************************
               proc     writemem

               extrn    addressmode
               extrn    load_d
               extrn    writememb
;               extrn    setvram

               push     ra             ; save address
               call7    load_d         ; need to get address mode
               dw       addressmode
               smi      'L'            ; check for little endian
               lbz      little         ; jump if so
               glo      rd             ; save low byte
               stxd
               ghi      rd             ; write high byte
writeword:     call    writememb
               irx                     ; recover low byte
               ldx
               inc      ra             ; increment address
               call     writememb      ; write low byte
               pop      ra             ; recover address
               rtn                     ; return to caller
little:        ghi      rd             ; save high byte
               stxd
               glo      rd             ; get low byte
               lbr      writeword      ; and write word



;               push     ra             ; save address
;               push     rd             ; save value
;               call     setvram        ; setup VRAM for write
;               glo      rd             ; move to fildes flags byts
;               adi      8
;               plo      rd
;               ghi      rd
;               adci     0
;               phi      rd
;               ldn      rd             ; retrieve flags
;               ori      011h           ; mark sector as modified
;               str      rd             ; put it back
;               pop      rd             ; recover value to write
;               call7    load_d         ; need to get address mode
;               dw       addressmode
;               smi      'L'            ; check for little endian
;               lbz      little         ; jump if so
;               ghi      rd             ; write value to vram
;               str      ra
;               inc      ra
;               glo      rd
;               str      ra
;               pop      ra             ; recover address
;               rtn                     ; and return to caller
;little:        glo      rd             ; write value as little endian
;               str      ra
;               inc      ra
;               ghi      rd
;               str      ra
;               pop      ra             ; recover address
;               rtn                     ; then return to caller
               endp


; void writeMem(word address, word value) {
;   if (addressMode == 'L') {
;     memory[address] = value & 0xff;
;     memory[address+1] = (value >> 8) & 0xff;
;     }
;   else {
;     memory[address+1] = value & 0xff;
;     memory[address] = (value >> 8) & 0xff;
;     }
;   map[address] = 1;
;   map[address+1] = 1;
;   }

