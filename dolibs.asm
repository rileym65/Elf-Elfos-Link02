#include       macros.inc
#include       ../kernel.inc

; *************************************************
; ***** Attempt to use libraris to resolve    *****
; ***** remaining unresolved references       *****
; *************************************************
               proc     dolibs

               extrn    dolink
               extrn    libraries
               extrn    libscan
               extrn    load_rf
               extrn    loadfile
               extrn    refcount
               extrn    resolved
               extrn    set_byte

again:         call7    load_rf        ; get beginning of library table
               dw       libraries
loop:          ldn      rf             ; check for end of table
               lbz      done           ; jump if so
               push     rf             ; save position
               call7    set_byte       ; set to library scan
               dw       libscan
               db       0ffh
               call     loadfile       ; load the file
               lbdf     fileerror      ; jump if error occurred
               pop      rf
eloop:         lda      rf             ; find name terminator
               lbnz     eloop
               lbr      loop           ; process next library
fileerror:     pop      rf             ; remove position from stack
               call     o_inmsg        ; display error
               db       'Errors: aborting link',10,13,0
               lbr      o_wrmboot      ; return to Elf/OS

done:          call     dolink         ; attempt to resove symbols
               call     refcount       ; get count of unresolved symbols
               glo      rc
               str      r2
               ghi      rc
               or
               lbz      nomore         ; jump if all symbols resolved
               call7    load_rf        ; get number of resolved references
               dw       resolved
               glo      rf             ; were there any?>
               str      r2
               ghi      rf
               or
               lbnz     again          ; if so, try another library scan
nomore:        rtn                     ; return to caller

               endp


