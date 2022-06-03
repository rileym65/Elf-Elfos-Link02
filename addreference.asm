#include       macros.inc
; ************************************************
; ***** Find symbol value                    *****
; ***** RF - pointer to symbol               *****
; ***** RD - reference value                 *****
; ***** RB.0 - Low byte offset               *****
; *****  D - reference type                  *****
; ************************************************
               proc     addreference

               extrn    load_ra
               extrn    store_ra
               extrn    referencesend

               str      r2             ; save reference type
               call7    load_ra        ; retrieve address of reference end
               dw       referencesend
loop:          lda      rf             ; get byte from symbol
               str      ra             ; write to reference table
               inc      ra
               lbnz     loop           ; loop until terminator is written
               ghi      rd             ; write reference value to table
               str      ra
               inc      ra
               glo      rd
               str      ra
               inc      ra
               glo      rb             ; write low byte offset
               str      ra
               inc      ra
               ldn      r2             ; recover reference type
               str      ra             ; write to reference table
               inc      ra
               ldi      0              ; write table terminator
               str      ra
               call7    store_ra       ; write new reference table end
               dw       referencesend
               rtn                     ; and return to caller
               endp

; reference table structure
; n-bytes - Name of reference
; 2-bytes - Address 
; 1-byte  - Low byte offset
; 1-btye  - Type
;           W - word reference
;           H - high byte reference
;           L - low byte reference
;           R - requires
;           X - used requires

; void addReference(char* name, word value, char typ) {
;   numReferences++;
;   if (numReferences == 1) {
;     references = (char**)malloc(sizeof(char*));
;     addresses = (word*)malloc(sizeof(word));
;     types = (char*)malloc(sizeof(char));
;     }
;   else {
;     references = (char**)realloc(references,sizeof(char*)*numReferences);
;     addresses = (word*)realloc(addresses,sizeof(word)*numReferences);
;     types = (char*)realloc(types,sizeof(char)*numReferences);
;     }
;   references[numReferences-1] = (char*)malloc(strlen(name) + 1);
;   strcpy(references[numReferences-1], name);
;   addresses[numReferences-1] = value;
;   types[numReferences-1] = typ;
;   }

