#include       macros.inc
#include       ../kernel.inc

; ***********************************************
; ***** Move past any white space           *****
; ***** RF - Pointer to String              *****
; ***** Returns: RF - First non-white space *****
; ***********************************************
               proc     outputelfos

               extrn    binopened
               extrn    buffer
               extrn    fildes1
               extrn    highest
               extrn    load_ra
               extrn    load_rb
               extrn    lowest
               extrn    outname
               extrn    startaddress

               push     r7             ; save consumed registers
               mov      rd,fildes1     ; point to general fildes
               mov      rf,outname     ; point to output filename
               ldi      3              ; create/truncate file
               plo      r7
               ldi      0
               phi      r7
               call     o_open         ; call Elf/OS to open file
               lbnf     opened         ; jump if the file was opened
               call     o_inmsg        ; display error message
               db       'Error: Could not open output file',10,13,0
               lbr      o_wrmboot      ; and return to Elf/OS
opened:        mov      rf,buffer      ; point to output buffer
               call7    load_ra        ; get load address
               dw       lowest       
               ghi      ra             ; and write to buffer
               str      rf
               inc      rf
               glo      ra
               str      rf
               inc      rf
               call7    load_rb        ; get highest address
               dw       highest
               glo      ra             ; subtract lowest rom highest
               str      r2
               glo      rb
               sm
               plo      rb
               ghi      ra
               str      r2
               smb
               phi      rb
               inc      rb             ; rb now has byte count
               ghi      rb             ; write to output buffer
               str      rf
               inc      rf
               glo      rb
               str      rf
               inc      rf
               call7    load_ra        ; get start address
               dw       startaddress
               ghi      ra             ; and write to output buffer
               str      rf
               inc      rf
               glo      ra
               str      rf
               mov      rf,buffer      ; point back to beginning of buffer
               ldi      6              ; 6 bytes to write
               plo      rc
               ldi      0
               phi      rc
               call     o_write        ; write executable header
               lbnf     binopened      ; then output as binary if no error
               call     o_inmsg        ; display error message
               db       'Error writing output file',10,13,0
               lbr      o_wrmboot      ; return to Elf/OS
               endp


; void outputElfos() {
;   int file;
;   word load;
;   word size;
;   word exec;
;   char header[6];
;   exec = startAddress;
;   load = lowest;
;   size = (highest-lowest) + 1;
;   header[0] = (load >> 8) & 0xff;
;   header[1] = load & 0xff;
;   header[2] = (size >> 8) & 0xff;
;   header[3] = size & 0xff;
;   header[4] = (exec >> 8) & 0xff;
;   header[5] = exec & 0xff;
;   file = open(outName, O_WRONLY | O_CREAT | O_TRUNC|O_BINARY, 0666);
;   write(file, header, 6);
;   write(file, memory+lowest, (highest-lowest)+1);
;   close(file);
;   }

