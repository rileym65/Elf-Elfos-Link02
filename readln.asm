#include       macros.inc
#include       ../kernel.inc

; ****************************************************
; ***** Read line from input                     *****
; ***** RD - File descriptor to read from        *****
; ***** RF - Pointer to buffer                   *****
; ***** Returns: DF=1 - EOF                      *****
; *****          DF=0 - valid read               *****
; *****          RC   - characters read          *****
; ****************************************************
               proc     readln

               mov      rc,0           ; set byte count
               mov      rb,pos         ; retrieve current position
               lda      rb
               phi      r9
               lda      rb
               plo      r9
               lda      rb             ; get bytes remaining
               plo      ra
loop:          glo      ra             ; do we have characters to read
               lbz      readfile       ; read more if not
               dec      ra             ; decrement byte count
               lda      r9             ; get next byte
               plo      re             ; keep a copy
               smi      10             ; check for line ending
               lbz      lineend        ; jump if so
               smi      3              ; check CR as well
               lbz      lineend
               glo      re             ; recover character
               str      rf             ; write into return buffer
               inc      rf
               inc      rc             ; increment bytes read
               lbr      loop           ; loop until line ending
lineend:       glo      rc             ; have we read any bytes
               lbz      loop           ; if not, then ignore and keep reading
retline:       ldi      0              ; terminate read line
               str      rf
               mov      rb,pos         ; write new position
               ghi      r9
               str      rb
               inc      rb
               glo      r9
               str      rb
               inc      rb
               glo      ra             ; store bytes remaining
               str      rb
               adi      0              ; indicate not EOF
               rtn                     ; and return to caller
readfile:      push     rf             ; push consumed registers
               push     rc
               mov      rf,buffer      ; point to input buffer
               mov      rc,128         ; read 128 bytes
               call     o_read         ; call Elf/OS to read bytes
               lbnf     noerror        ; jump if no error on read
               call     o_inmsg        ; display read error
               db       'Error: Error reading from file',10,13,0
               lbr      o_wrmboot      ; return to Elf/OS
noerror:       mov      r9,buffer      ; point to input buffer
               glo      rc             ; were bytes read
               plo      ra             ; set bytes remaining
               lbz      eof            ; jump if not
               pop      rc             ; recover consumed registers
               pop      rf
               lbr      loop           ; continue processing input
eof:           pop      rc             ; recover consumed registers
               pop      rf
               glo      rc             ; were any bytes transferred
               lbnz     retline        ; return what was read as normal
               smi      0              ; set DF to indicate EOF
               rtn                     ; and return
            


readlnrst:     mov      rf,count       ; mark buffer empty
               ldi      0
               str      rf
               rtn                     ; return to caller

buffer:        ds       128
pos:           dw       0
count:         db       0

               public   readlnrst

               endp
