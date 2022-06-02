#include       macros.inc
; ************************************************
; ***** Find symbol value                    *****
; ***** RF - pointer to library name         *****
; ************************************************
               proc     addlibrary

               extrn    librariesend
               extrn    load_ra
               extrn    store_ra

               call7    load_ra        ; get value of libraries end
               dw       librariesend
loop:          lda      rf             ; get byte from library name
               str      ra             ; write to library table
               inc      ra
               lbnz     loop           ; loop until terminator is written
               ldi      0              ; write table terminator
               str      ra
               call7    store_ra       ; wrie new libraries table end
               dw       librariesend
               rtn                     ; and return to caller
               endp


; void addLibrary(char* name) {
;   numLibraries++;
;   if (numLibraries == 1)
;     libraries = (char**)malloc(sizeof(char*));
;   else
;     libraries = (char**)realloc(libraries,sizeof(char*)*numLibraries);
;   libraries[numLibraries-1] = (char*)malloc(strlen(name)+1);
;   strcpy(libraries[numLibraries-1],name);
;   }

