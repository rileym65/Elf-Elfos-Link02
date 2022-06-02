#include       macros.inc
#include       ../kernel.inc

; ***********************************************
; ***** Move past any white space           *****
; ***** RF - Pointer to String              *****
; ***** Returns: RF - First non-white space *****
; ***********************************************
               proc     outputbinary

               extrn    buffer
               extrn    fildes1
               extrn    highest
               extrn    load_ra
               extrn    load_rb
               extrn    lowest
               extrn    outname
               extrn    readmemb

               push     r7             ; save consumed registers
               mov      rd,fildes1     ; point to general fildes
               mov      rf,outname     ; point to output filename
               ldi      3              ; create/truncate file
               plo      r7
               ldi      0
               phi      r7
               call     o_open         ; call Elf/OS to open file
               lbnf     binopened      ; jump if the file was opened
               call     o_inmsg        ; display error message
               db       'Error: Could not open output file',10,13,0
               lbr      o_wrmboot      ; and return to Elf/OS
binopened:     call7    load_rb        ; need highest address
               dw       highest
               call7    load_ra        ; need lowest address
               dw       lowest
               glo      ra             ; compute difference
               str      r2
               glo      rb
               sm
               plo      rb             ; put difference into RB
               ghi      ra
               str      r2
               ghi      rb
               smb
               phi      rb
               inc      rb             ; RB now has total number of bytes
               mov      rf,buffer      ; point to buffer
loop:          glo      rb             ; are we done
               lbnz     notdone        ; jump if not
               ghi      rb             ; check high byte
               lbnz     notdone
               glo      rc             ; see if buffer is empty
               lbz      alldone        ; if so then close the file
               mov      rf,buffer      ; need to write final buffer
               call     o_write        ; write final buffer
               lbnf     alldone        ; jump if done
               call     o_inmsg        ; otherwise error message
               db       'Error: error during write',10,13,0
               lbr      o_wrmboot      ; return to Elf/OS
alldone:       call     o_close        ; close the file
               pop      r7             ; recover used registers
               rtn                     ; and return to caller
notdone:       mov      rf,buffer      ; point to buffer
               ldi      0              ; clear counter
               plo      rc
               phi      rc
copylp:        push     ra             ; save consumed registers
               call     readmemb       ; get byte from VRAM
               plo      re             ; save byte
               pop      ra             ; recover consumed registers
               glo      re             ; get byte
               str      rf             ; store into buffer
               inc      rf
               dec      rb             ; decrement bytes to write
               inc      rc             ; increment byte count
               glo      rc             ; see if 128 bytes accumulated
               shl
               lbnf     loop           ; loop until buffer full
               push     ra             ; save important registers
               push     rb
               mov      rf,buffer      ; setup for write
               call     o_write        ; write buffer to disk
               pop      rb             ; recover registers
               pop      ra
               mov      rf,buffer      ; point back to buffer
               lbnf     loop           ; loop back for more if no error
               call     o_inmsg        ; dislay write error
               db       'Error: error during write',10,13,0
               lbr      o_wrmboot      ; return to Elf/OS

               public   binopened

               endp

; void outputBinary() {
;   int file;
;   file = open(outName, O_WRONLY | O_CREAT | O_TRUNC|O_BINARY, 0666);
;   write(file, memory+lowest, (highest-lowest)+1);
;   close(file);
;   }
