#include       macros.inc
; ****************************************************
; ***** Convert D to 2 hex digits                *****
; ***** R9 - Where to put                        *****
; ***** Returns: R9   - incremented              *****
; ****************************************************
               proc     outhex2

               plo      re             ; keep a copy
               shr                     ; move high nybble to low
               shr
               shr
               shr
               smi      10             ; check for greater than 9
               lbnf     highnum        ; jump if not
               adi      'A'            ; convert to hex digit
               lbr      highwrt        ; and output it
highnum:       adi      '0'+10         ; convert to ascii
highwrt:       str      r9             ; write character to output
               inc      r9
               glo      re             ; recover original value
               ani      0fh            ; keep only low nybble
               smi      10             ; check for greater than 9
               lbnf     lownum         ; jump if not
               adi      'A'            ; convert to hex digit
               lbr      lowwrt         ; and output it
lownum:        adi      '0'+10         ; convert to ascii
lowwrt:        str      r9             ; store into output
               inc      r9
               rtn                     ; return to caller

               endp
