#include       macros.inc

; ****************************************************
; ***** Check next character for hex value       *****
; ***** RF - Pointer to character                *****
; ***** Returns: DF=1 - value was hex            *****
; *****          DF=0 - value was not hex        *****
; *****           D=n - hex value of digit       *****
; *****          RF   - incremented if hex digit *****
; ****************************************************
               proc     dolink

               extrn    findsymbol
               extrn    load_rb
               extrn    load_rf
               extrn    prune
               extrn    readmem
               extrn    readmemb
               extrn    references
               extrn    resolved
               extrn    set_word
               extrn    store_rb
               extrn    writemem
               extrn    writememb
             
               call7    load_rf        ; retrieve start of references
               dw       references
               call7    set_word       ; clear resolved count
               dw       resolved
               dw       0
loop:          ldn      rf             ; check for end of table
               lbz      done           ; jump if end of table
               mov      rb,rf          ; need to find end of symbol
sloop:         lda      rb             ; get byte from symbol name
               lbnz     sloop          ; loop until terminator found
               lda      rb             ; get address
               phi      ra
               lda      rb
               plo      ra
               lda      rb             ; retrieve low byte offset
               plo      r9             ; set it here
               lda      rb             ; get type
               plo      re             ; keep a copy of type
               smi      'R'            ; is it a requires
               lbz      nextentry      ; jump if so
               glo      re             ; recover type
               smi      'X'            ; check also for used requires
               lbz      nextentry      ; jump if so
               push     rb             ; save pointer to next entry
               glo      re             ; get type
               stxd                    ; and store it
               push     ra             ; save address
               call     findsymbol     ; search for symbol
               lbnf     notfound       ; jump if symbol not found
               mov      rd,ra          ; move symbol value to RD
               pop      ra             ; recover reference address
               irx                     ; recover type
               ldx
               plo      re             ; keep a copy
               smi      'W'            ; is it a word
               lbz      linkword       ; jump if so
               glo      re             ; recover type
               smi      'H'            ; is it high
               lbz      linkhigh       ; jump if so
               glo      re             ; recover type
               smi      'L'            ; is it low
               lbnz     nogood         ; invalid reference, so skip it
               glo      rd             ; want low of symbol value
linkbyte:      stxd                    ; store it
               call     readmemb       ; read byte at address
               irx                     ; add symbol value
               add
               call     writememb      ; write new value back
               lbr      entrydone      ; done with entry
linkhigh:      glo      r9             ; add lsb offset to address
               str      r2
               glo      rd
               add
               ghi      rd
               adci     0
               lbr      linkbyte       ; then process byte
linkword:      push     rd             ; save value
               call     readmem        ; read word at address
               pop      rb             ; recover symbol value
               glo      rb             ; add to RD
               str      r2
               glo      rd
               add
               plo      rd
               ghi      rb
               str      r2
               ghi      rd
               adc
               phi      rd             ; RD now has corrected value
               call     writemem       ; write it back
entrydone:     pop      rf             ; get address to next entry
               dec      rf             ; back to prior type byte
               ldi      '*'            ; mark as completed
               str      rf
               inc      rf             ; point back to next entry
               call7    load_rb        ; get resoved count
               dw       resolved
               inc      rb             ; increment it
               call7    store_rb       ; and write it back
               dw       resolved
               lbr      loop           ; and process next entry
notfound:      pop      ra             ; recover address
               irx                     ; ignore type
nogood:        pop      rf             ; pointer to next entry
               lbr      loop           ; check next entry
nextentry:     mov      rf,rb          ; point to next entry
               lbr      loop           ; and check it
done:          call     prune          ; prune out resolved references
               rtn                     ; and return to caller

               endp

