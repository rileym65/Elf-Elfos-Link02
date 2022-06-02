#include       macros.inc
; ****************************************************
; ***** Check next character for hex value       *****
; ***** RF - Pointer to character                *****
; ***** Returns: DF=1 - value was hex            *****
; *****          DF=0 - value was not hex        *****
; *****           D=n - hex value of digit       *****
; *****          RF   - incremented if hex digit *****
; ****************************************************
               proc     ishex
               ldn      rf             ; get character to check
               smi      48             ; check if below '0'
               lbnf     nothex         ; jump if below '0'
               smi      10             ; check for '0' through '9'
               lbdf     notnum         ; jumpt if not a numeral
               adi      10             ; convert to binary
               lbr      yeshex         ; and flag as hex
notnum:        smi      7              ; see if below 'A'
               lbnf     nothex         ; jump if below 'A'
               smi      6              ; check if above 'F'
               lbdf     notuc          ; jump if not uppercase
               adi      16             ; convert to binary
               lbr      yeshex         ; and flag as hex
notuc:         smi      26             ; check if below 'a'
               lbnf     nothex         ; jump if below 'a'
               smi      6              ; check for above 'f'
               lbdf     nothex         ; jump if above 'f'
               adi      16             ; convert to binary
yeshex:        inc      rf             ; point to next character
               smi      0              ; indicate char was hex
               rtn                     ; and return
nothex:        adi      0              ; Signal was not hex
               rtn                     ; and return to caller
               endp
