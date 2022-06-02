#include       macros.inc
; *************************************************
; ***** Get Hex from string                   *****
; ***** RF - pointer to string                *****
; ***** Returns: RD - Hex value               *****
; *****          RF - First non-hex character *****
; *************************************************
               proc     gethex

               extrn    ishex

               ldi      0              ; set return value to zero
               phi      rd
               plo      rd
loop:          call     ishex          ; is next character hex
               lbnf     done           ; jump if not
               str      r2             ; save new digit value
               ldi      4              ; need to shift 4 places
               plo      re
shiftlp:       glo      rd             ; shift low byte
               shl
               plo      rd
               ghi      rd             ; shift high byte
               shlc
               phi      rd
               dec      re             ; decrement count
               glo      re             ; see if done
               lbnz     shiftlp        ; loop until all 4 shifts done
               glo      rd             ; now combine with new value
               or
               plo      rd             ; and put it back
               lbr      loop           ; loop until non-hex found
done:          rtn                     ; return to caller

               endp

; char* getHex(char* line, word *value) {
;   *value = 0;
;   while ((*line >= '0' && *line <= '9') ||
;          (*line >= 'a' && *line <= 'f') ||
;          (*line >= 'A' && *line <= 'F')) {
;     if (*line >= '0' && *line <= '9')
;       *value = (*value << 4) + (*line - '0');
;     else if (*line >= 'a' && *line <= 'f')
;       *value = (*value << 4) + (*line - 87);
;     else if (*line >= 'A' && *line <= 'F')
;       *value = (*value << 4) + (*line - 65);
;     line++;
;     }
;   return line;
;   }

