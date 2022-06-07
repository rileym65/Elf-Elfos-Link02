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

               endp

