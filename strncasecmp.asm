#include       macros.inc
; ***********************************************
; ***** Compare two strings for equality    *****
; ***** RF - pointer to string 1            *****
; ***** RD - pointer to string 2            *****
; ***** RC - Characters to compare          *****
; ***** Returns: DF=1 - Strings are equal   *****
; *****          DF=0 - Strings are unequal *****
; *****          RF   - After match         *****
; *****          RD   - After match         *****
; ***********************************************
               proc     strncasecmp

               extrn    chartoupper

               lda      rf             ; get byte from first string
               call     chartoupper    ; make sure it is uppercase
               stxd                    ; store for compare
               lda      rd             ; get byte from second string
               call     chartoupper    ; make sure it is uppercase
               irx
               sm                      ; compare
               lbnz     bad            ; jump if no match
               dec      rc             ; decrement characters to compare
               glo      rc             ; see if done
               lbnz     strncasecmp    ; loop if not done
               ghi      rc             ; check high byte
               lbnz     strncasecmp
               smi      0              ; set DF
               rtn                     ; and return
bad:           adi      0              ; clear DF
               rtn                     ; and return

               endp
