#include       macros.inc
#include       ../kernel.inc

; ***********************************************
; ***** Write output as RCS hex             *****
; ***** Intern:  RA - address pointer       *****
; *****          RB - bytes remaining       *****
; *****          RC.0 bytes on line         *****
; *****          R9 - line buffer           *****
; ***********************************************
               proc     outputrcs

               extrn    buffer
               extrn    fildes1
               extrn    highest
               extrn    load_ra
               extrn    load_rb
               extrn    lowest
               extrn    microint
               extrn    outhex2
               extrn    outhex4
               extrn    outname
               extrn    outwrterr
               extrn    readmap
               extrn    readmemb
               extrn    startaddress

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
opened:        mov      r7,microint
               call7    load_rb        ; need highest address
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
               call7    load_ra        ; get lowest address
               dw       lowest
               ldi      0              ; set count to zero
               plo      rc
loop:          call     readmap        ; see if byte set at address
               lbnf     nobyte         ; jump if no byte at address
               glo      rc             ; first byte on line?
               lbnz     notfirst       ; jump if not
               mov      r9,buffer      ; point R9 to output buffer
               ldi      ':'            ; write data marker to output
               str      r9
               inc      r9
               call     outhex4        ; write address
notfirst:      ldi      ' '            ; write space to buffer
               str      r9
               inc      r9
               call     readmemb       ; read byte from vram
               call     outhex2        ; write byte to buffer
               inc      rc             ; increment bytes on line
               glo      rc             ; have 16 bytes been output
               smi      16
               lbnz     endloop        ; jump if not
               call     writeline      ; write the line
               ldi      0              ; clear bytes on line counter
               plo      rc
               lbr      endloop        ; then to end of loop
nobyte:        glo      rc             ; are there bytes on current line
               lbz      endloop        ; jump if not
               call     writeline      ; write out current line
               ldi      0              ; clear bytes per line
               plo      rc
               lbr      endloop        ; then to end of loop
endloop:       inc      ra             ; increment address
               dec      rb             ; decrement byte count
               glo      rb             ; see if done
               lbnz     loop           ; continue if not
               ghi      rb             ; check high byte as well
               lbnz     loop
               glo      rc             ; have bytes been written to final line
               lbz      noendline      ; jump if not
               call     writeline      ; write final line
noendline:     call7    load_ra        ; get start address
               dw       startaddress
               ghi      ra             ; was start address specified
               smi      0ffh
               lbnz     needstart
               glo      ra
               smi      0ffh
               lbnz     needstart
done:          call     o_close        ; close the file
               rtn                     ; and return to caller
needstart:     mov      r9,buffer      ; point to buffer
               ldi      '@'            ; need execution marker
               str      r9
               inc      r9
               call     outhex4        ; write start address
               call     writeline      ; then write line to file
               lbr      done           ; all done
writeline:     ldi      10             ; write line terminator
               str      r9
               inc      r9
               ldi      13
               str      r9
               inc      r9
               glo      r9             ; compute line size
               smi      buffer.0
               plo      rc
               ghi      r9
               smbi     buffer.1
               phi      rc             ; RC now has count
               mov      rf,buffer      ; point to buffer
               mov      rd,fildes1     ; point to fildes
               call     o_write        ; call Elf/OS to write line
               lbdf     outwrterr      ; jump if error
               rtn                     ; return to caller

               endp


; void outputRcs() {
;   int   i;
;   FILE* file;
;   byte  buffer[16];
;   char  line[256];
;   char  tmp[5];
;   byte  count;
;   word  outAddress;
;   int   address;
;   int   high;
;   address = lowest;
;   high = highest;
;   outAddress = lowest;
;   count = 0;
;   file = fopen(outName, "w");
;   while (address <= high) {
;     if (map[address] == 1) {
;       if (count == 0) outAddress = address;
;       buffer[count++] = memory[address];
;       if (count == 16) {
;         strcpy(line,":");
;         sprintf(tmp,"%04x",outAddress);
;         strcat(line,tmp);
;         for (i=0; i<count; i++) {
;           sprintf(tmp," %02x",buffer[i]);
;           strcat(line,tmp);
;           }
;         fprintf(file,"%s\n",line);
;         count = 0;
;         }
;       }
;     else if (count > 0) {
;       strcpy(line,":");
;       sprintf(tmp,"%04x",outAddress);
;       strcat(line,tmp);
;       for (i=0; i<count; i++) {
;         sprintf(tmp," %02x",buffer[i]);
;         strcat(line,tmp);
;         }
;       fprintf(file,"%s\n",line);
;       count = 0;
;       }
;     address++;
;     }
;   if (count > 0) {
;     strcpy(line,":");
;     sprintf(tmp,"%04x",outAddress);
;     strcat(line,tmp);
;     for (i=0; i<count; i++) {
;       sprintf(tmp," %02x",buffer[i]);
;       strcat(line,tmp);
;       }
;     fprintf(file,"%s\n",line);
;     count = 0;
;     }
;   if (startAddress != 0xffff) {
;     sprintf(line,"@%04x",startAddress);
;     fprintf(file,"%s\n",line);
;     }
;   fclose(file);
;   }

