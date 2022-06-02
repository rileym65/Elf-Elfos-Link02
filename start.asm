#include       macros.inc
#include       ../kernel.inc

               extrn    buffer
               extrn    crlf
               extrn    dispsymbols
               extrn    dolibs
               extrn    dolink
               extrn    highest
               extrn    refcount
               extrn    lowest
               extrn    objcount
               extrn    outhex4
               extrn    outmode
               extrn    outname
               extrn    outputbinary
               extrn    outputelfos
               extrn    outputintel
               extrn    outputrcs
               extrn    processcl
               extrn    setup
               extrn    showsymbols
               extrn    showunres
               extrn    startaddress

               org      02000h
begin:         br       start
               eever
               db       'by Michael H. Riley',0

microret:      sep      r3             ; return to caller
microint:      plo      re
               lda      r3             ; read function
               plo      r7             ; jump to function
; **************************************
; ***** Set memory address to byte *****
; **************************************
set_byte:      lda      r3             ; get address
               phi      r8
               lda      r3
               plo      r8
               lda      r3             ; read byte
               str      r8             ; store it
               br       microret       ; and then return

; **************************************
; ***** Set memory address to word *****
; **************************************
set_word:      lda      r3             ; get address
               phi      r8
               lda      r3
               plo      r8
               lda      r3             ; get value to write
               str      r8             ; and write to memory
               inc      r8
               lda      r3
               str      r8
               br       microret

; **************************************
; ***** Read D from memory address *****
; **************************************
load_d:        lda      r3             ; get address
               phi      r8
               lda      r3
               plo      r8
               lda      r8
               br       microret

; *************************************
; ***** Write D to memory address *****
; *************************************
store_d:       plo      re             ; keep a copy
               lda      r3             ; get memory address
               phi      r8
               lda      r3
               plo      r8
               glo      re             ; recover byte
               str      r8             ; and store it
               br       microret

; *******************************
; ***** Load RF from memory *****
; *******************************
load_rf:       lda      r3             ; get address
               phi      rf
               lda      r3
               plo      rf
               lda      rf             ; read value from address
               plo      re             ; save high byte
               lda      rf
               plo      rf
               glo      re             ; get high byte
               phi      rf
               br       microret

; *******************************
; ***** Load RD from memory *****
; *******************************
load_rd:       lda      r3             ; get address
               phi      rd
               lda      r3
               plo      rd
               lda      rd             ; read value from address
               plo      re             ; save high byte
               lda      rd
               plo      rd
               glo      re             ; get high byte
               phi      rd
               br       microret

; *******************************
; ***** Load RB from memory *****
; *******************************
load_rb:       lda      r3             ; get address
               phi      rb
               lda      r3
               plo      rb
               lda      rb             ; read value from address
               plo      re             ; save high byte
               lda      rb
               plo      rb
               glo      re             ; get high byte
               phi      rb
               br       microret

; *******************************
; ***** Load RA from memory *****
; *******************************
load_ra:       lda      r3             ; get address
               phi      ra
               lda      r3
               plo      ra
               lda      ra             ; read value from address
               plo      re             ; save high byte
               lda      ra
               plo      ra
               glo      re             ; get high byte
               phi      ra
               br       microret

; ******************************
; ***** Store RF to memory *****
; ******************************
store_rf:      lda      r3             ; get address
               phi      r8
               lda      r3
               plo      r8
               ghi      rf
               str      r8
               inc      r8
               glo      rf
               str      r8
               br       microret

; ******************************
; ***** Store RD to memory *****
; ******************************
store_rd:      lda      r3             ; get address
               phi      r8
               lda      r3
               plo      r8
               ghi      rd
               str      r8
               inc      r8
               glo      rd
               str      r8
               br       microret

; ******************************
; ***** Store RB to memory *****
; ******************************
store_rb:      lda      r3             ; get address
               phi      r8
               lda      r3
               plo      r8
               ghi      rb
               str      r8
               inc      r8
               glo      rb
               str      r8
               br       microret

; ******************************
; ***** Store RA to memory *****
; ******************************
store_ra:      lda      r3             ; get address
               phi      r8
               lda      r3
               plo      r8
               ghi      ra
               str      r8
               inc      r8
               glo      ra
               str      r8
               br       microret

; ************************************
; ***** Compare D to immediate   *****
; ***** Returns: DF=1 - matched  *****
; *****          DF=0 - no match *****
; ************************************
cmp:           glo      re
               str      r2
               lda      r3
               sm
               bnz      cmpno
               ldn      r2
               smi      0
               br       microret
cmpno:         ldn      r2
               adi      0
               br       microret

; ********************************************************
; *****                  Main program                *****
; ********************************************************
start:         call     o_inmsg        ; display startup message
               db       'Link/02 v1.0',10,13
               db       'By Michael H. Riley',10,13,10,13,0
               push     ra             ; save CL arguments
               call     setup          ; setup everything
               pop      ra
               call     processcl
               call7    load_ra        ; get number of objects processed
               dw       objcount
               glo      ra             ; make sure at least 1 was processed
               lbnz     objgood        ; jump if so
               ghi      ra             ; check high byte as well
               lbnz     objgood
               call     o_inmsg        ; write error
               db       'No object files specifed',10,13,0
               lbr      o_wrmboot      ; then return to Elf/OS
objgood:       call     dolink         ; link loaded modules
               call     refcount       ; get count of unresolved references
               glo      rc             ; were there any
               str      r2
               ghi      rc
               or
               lbz      donelink       ; jump if done with linking
               call     dolibs         ; check against libraries
               call     refcount       ; get count of unresolved references
               glo      rc
               str      r2
               ghi      rc
               or
               lbz      donelink       ; jump if all are resolved
               call     showunres      ; show unresolved symbols
               lbr      o_wrmboot      ; and return to Elf/OS
donelink:      mov      rf,outname     ; point to outname
outnmlp:       lda      rf             ; need either zero or .
               lbz      outnmdn        ; jump if end found
               call7    cmp
               db       '.'
               lbnf     outnmlp        ; loop until found
outnmdn:       dec      rf             ; move back to terminator or .
               call7    load_d         ; get output mode
               dw       outmode
               call7    cmp            ; binary mode?
               db       1
               lbdf     outbin         ; jump if so
               call7    cmp            ; elfos mode?
               db       2
               lbdf     outelfos       ; jump if so
               call7    cmp            ; intel hex mode
               db       5
               lbdf     outintel       ; jump if so
               call     append         ; append .prg extension
               db       '.rcs',0
               call     outputrcs      ; write output as RCS hex
               lbr      donefile       ; done with output file
outbin:        call     append         ; append .bin
               db       '.bin',0
               call     outputbinary   ; write output as binary
               lbr      donefile       ; done with output
outelfos:      call     append         ; append .elf
               db       '.elf',0
               call     outputelfos    ; output as elfos file
               lbr      donefile
outintel:      call     append         ; append .hex
               db       '.hex',0
               call     outputintel    ; output as intel hex
donefile:      call     o_inmsg        ; write message
               db       'Lowest address : ',0
               mov      r9,buffer      ; buffer for address
               call7    load_ra        ; get lowest address
               dw       lowest
               call     outhex4        ; convert to ascii
               ldi      0              ; write terminator
               str      r9
               mov      rf,buffer      ; and display it
               call     o_msg
               call     crlf
               call     o_inmsg        ; write highest address
               db       'Highest address: ',0
               mov      r9,buffer
               call7    load_ra
               dw       highest
               call     outhex4
               ldi      0              ; write terminator
               str      r9
               mov      rf,buffer
               call     o_msg
               call     crlf
               call7    load_ra        ; get start address
               dw       startaddress
               glo      ra             ; see if start address was provided
               smi      0ffh
               lbnz     showstart      ; jump if so
               ghi      ra             ; check high byte
               smi      0ffh
               lbz      nostart        ; no start address given
showstart:     call     o_inmsg        ; display message
               db       'Start address  : ',0
               mov      r9,buffer
               call7    load_ra
               dw       startaddress
               call     outhex4
               ldi      0              ; write terminator
               str      r9
               mov      rf,buffer
               call     o_msg
               call     crlf
nostart:       call7    load_d         ; was show symbols specified?
               dw       showsymbols
               lbz      alldone        ; jump if all done
               call     dispsymbols    ; display public symbols
alldone:       call     crlf           ; final crlf
               lbr      o_wrmboot      ; and return to Elf/OS

append:        lda      r6             ; get byte from source
               str      rf             ; store into name
               inc      rf
               lbnz     append         ; loop until terminator copied
               rtn                     ; then return

               end      begin

               public   cmp
               public   microint
               public   set_byte
               public   set_word
               public   load_d
               public   load_ra
               public   load_rb
               public   load_rd
               public   load_rf
               public   store_d
               public   store_ra
               public   store_rb
               public   store_rd
               public   store_rf


; int main(int argc, char **argv) {
;   int   i;
;   char *pchar;
;   printf("Link/02 v1.0\n");
;   printf("By Michael H. Riley\n\n");
;   lowest = 0xffff;
;   highest = 0x0000;
;   numObjects = 0;
;   startAddress = 0xffff;
;   showSymbols = 0;
;   numSymbols = 0;
;   numReferences = 0;
;   numLibraries = 0;
;   numRequires = 0;
;   addressMode = 'L';
;   strcpy(outName,"");
;   outMode = BM_BINARY;
;   for (i=1; i<argc; i++) {
;     if (strcmp(argv[i], "-b") == 0) outMode = BM_BINARY;
;     else if (strcmp(argv[i], "-c") == 0) outMode = BM_CMD;
;     else if (strcmp(argv[i], "-e") == 0) outMode = BM_ELFOS;
;     else if (strcmp(argv[i], "-i") == 0) outMode = BM_INTEL;
;     else if (strcmp(argv[i], "-h") == 0) outMode = BM_RCS;
;     else if (strcmp(argv[i], "-s") == 0) showSymbols = -1;
;     else if (strcmp(argv[i], "-be") == 0) addressMode = 'B';
;     else if (strcmp(argv[i], "-le") == 0) addressMode = 'L';
;     else if (strcmp(argv[i], "-o") == 0) {
;       i++;
;       strcpy(outName, argv[i]);
;       }
;     else if (argv[i][0] == '@') {
;       readControlFile(argv[i]+1);
;       }
;     else if (strcmp(argv[i], "-l") == 0) {
;       i++;
;       addLibrary(argv[i]);
;       }
;     else {
;       addObject(argv[i]);
;       }
;     }
;   if (numObjects == 0) {
;     printf("No object files specified\n");
;     exit(1);
;     }
;   if (strlen(outName) == 0) {
;     strcpy(outName, objects[0]);
;     pchar = strchr(outName, '.');
;     if (pchar != NULL) *pchar = 0;
;     if (outMode == BM_BINARY) strcat(outName, ".bin");
;     if (outMode == BM_CMD) strcat(outName, ".cmd");
;     if (outMode == BM_ELFOS) strcat(outName, ".elfos");
;     if (outMode == BM_INTEL) strcat(outName, ".intel");
;     if (outMode == BM_RCS) strcat(outName, ".hex");
;     }
;   for (i=0; i<65536; i++) {
;     memory[i] = 0;
;     map[i] = 0;
;     }
;   address = 0;
;   resolved = 0;
;   libScan = 0;
;   loadModule = -1;
;   for (i=0; i<numObjects; i++)
;     if (loadFile(objects[i]) < 0) {
;       printf("Errors: aborting link\n");
;       exit(1);
;       }
;   doLink();
;   resolved = 1;
;   while (numReferences > 0 && resolved != 0) {
;     libScan = -1;
;     for (i=0; i<numLibraries; i++) {
;       loadModule = 0;
;       if (loadFile(libraries[i]) < 0) {
;         printf("Errors: aborting link\n");
;         exit(1);
;         }
;       }
;     doLink();
;     }
;   if (numReferences > 0) {
;     for (i=0; i<numReferences; i++) {
;       printf("Error: Symbol %s not found\n",references[i]);
;       }
;     printf("Errors during link.  Aborting output\n");
;     exit(1);
;     }
;   else {
;     printf("Writing: %s\n",outName);
;     switch (outMode) {
;       case BM_BINARY: outputBinary(); break;
;       case BM_ELFOS : outputElfos(); break;
;       case BM_INTEL : outputIntel(); break;
;       case BM_RCS   : outputRcs(); break;
;       }
;     }
;   printf("Lowest address : %04x\n",lowest);
;   printf("Highest address: %04x\n",highest);
;   if (startAddress != 0xffff)
;     printf("Start address  : %04x\n",startAddress);
;   if (showSymbols) {
;     sortSymbols();
;     for (i=0; i<numSymbols; i++)
;       printf("%-20s %04x\n",symbols[i], values[i]);
;     }
;   printf("\n");
;   return 0;
;   }

