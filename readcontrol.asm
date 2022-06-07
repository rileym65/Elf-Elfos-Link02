#include       macros.inc
#include       ../kernel.inc

; ****************************************************
; ***** Read control file                        *****
; ***** RF - Pointer to filename                 *****
; ****************************************************
               proc     readcontrol

               extrn    addlibrary
               extrn    addressmode
               extrn    buffer
               extrn    buffer2
               extrn    cmp
               extrn    crlf
               extrn    ctrldta
               extrn    ctrlfildes
               extrn    fileerr
               extrn    load_rf
               extrn    loadfile
               extrn    microint
               extrn    objcount
               extrn    outmode
               extrn    outname
               extrn    set_byte
               extrn    store_rf
               extrn    strcasecmp
               extrn    strncasecmp
               extrn    trim

               push     rf             ; save filename pointer
               mov      rd,ctrlfildes+4  ; Need to setup DTA for control fildes
               ldi      ctrldta.1
               str      rd
               inc      rd
               ldi      ctrldta.0
               str      rd
               mov      rd,ctrlfildes  ; Need to point to control file fildes
               mov      r7,0           ; nothing special on open
               call     o_open         ; open file
               lbnf     opened
               call     o_inmsg        ; display error
               db       'Could not open ',0
               pop      rf             ; recover filename
               call     o_msg          ; display it
               call     crlf           ; display crlf
               lbr      o_wrmboot      ; return to Elf/OS
opened:        irx                     ; remove filename pointer
               irx
               mov      r7,microint    ; be sure R7 is correct
loop:          call     readln         ; read next line
               lbdf     eof            ; jump if end of file

; ++++++++++++++++++++++++
; +++++ Check 'mode' +++++
; ++++++++++++++++++++++++
               mov      rf,buffer      ; point to input buffer
               mov      rd,lblmode     ; point to label
               mov      rc,5
               call     strncasecmp    ; compare strings
               lbnf     not_mode       ; jump if not
               mov      rf,buffer+5    ; point to string after mode
               call     trim           ; move past any whitespace

; ++++++++++++++++++++++++++
; +++++ Check 'binary' +++++
; ++++++++++++++++++++++++++
               mov      rf,buffer      ; point to input buffer
               mov      rd,lblbinary   ; point to label
               call     strcasecmp     ; compare strings
               lbnf     mode_1         ; jump if not
               call7    set_byte       ; set output mode to binary
               dw       outmode
               db       1
               lbr      loop           ; loop for next line

; +++++++++++++++++++++++++
; +++++ Check 'elfos' +++++
; +++++++++++++++++++++++++
mode_1:        mov      rf,buffer      ; point to input buffer
               mov      rd,lblelfos    ; point to label
               call     strcasecmp     ; compare strings
               lbnf     mode_2         ; jump if not
               call7    set_byte       ; set output mode to elfos
               dw       outmode
               db       2
               lbr      loop           ; loop for next line

; +++++++++++++++++++++++++
; +++++ Check 'intel' +++++
; +++++++++++++++++++++++++
mode_2:        mov      rf,buffer      ; point to input buffer
               mov      rd,lblintel    ; point to label
               call     strcasecmp     ; compare strings
               lbnf     mode_3         ; jump if not
               call7    set_byte       ; set output mode to elfos
               dw       outmode
               db       5
               lbr      loop           ; loop for next line

; +++++++++++++++++++++++
; +++++ Check 'rcs' +++++
; +++++++++++++++++++++++
mode_3:        mov      rf,buffer      ; point to input buffer
               mov      rd,lblrcs      ; point to label
               call     strcasecmp     ; compare strings
               lbnf     mode_4         ; jump if not
               call7    set_byte       ; set output mode to elfos
               dw       outmode
               db       4
               lbr      loop           ; loop for next line

; +++++++++++++++++++++++
; +++++ Check 'big' +++++
; +++++++++++++++++++++++
mode_4:        mov      rf,buffer      ; point to input buffer
               mov      rd,lblbig      ; point to label
               call     strcasecmp     ; compare strings
               lbnf     mode_5         ; jump if not
               call7    set_byte       ; set output mode to elfos
               dw       addressmode
               db       'B'
               lbr      loop           ; loop for next line

; ++++++++++++++++++++++++++
; +++++ Check 'little' +++++
; ++++++++++++++++++++++++++
mode_5:        mov      rf,buffer      ; point to input buffer
               mov      rd,lbllittle   ; point to label
               call     strcasecmp     ; compare strings
               lbnf     loop           ; ignore line for unknown mode
               call7    set_byte       ; set output mode to elfos
               dw       addressmode
               db       'L'
               lbr      loop           ; loop for next line
            
; ++++++++++++++++++++++++++
; +++++ check 'output' +++++
; ++++++++++++++++++++++++++
not_mode:      mov      rf,buffer      ; point to input buffer
               mov      rd,lbloutput   ; point to label
               mov      rc,7
               call     strncasecmp    ; compare strings
               lbnf     not_output     ; jump if not
               mov      rf,buffer+7    ; move past output
               call     trim           ; trim any whitespace
               mov      rd,outname     ; point to outname
output_lp:     lda      rf             ; get byte from input
               lbz      output_dn      ; jump if terminator
               call7    cmp            ; check for space
               db       ' '
               lbdf     output_dn      ; jump if space
               str      rd             ; otherwise store intput outname
               inc      rd
               lbr      output_lp      ; loop until done
output_dn:     ldi      0              ; need a terminator
               str      rd
               lbr      loop           ; process next line

; +++++++++++++++++++++++++++
; +++++ Check 'library' +++++
; +++++++++++++++++++++++++++
not_output:    mov      rf,buffer      ; point to input buffer
               mov      rd,lbllibrary  ; point to label
               mov      rc,8
               call     strncasecmp    ; compare strings
               lbnf     not_library    ; jump if not
               mov      rf,buffer+8    ; move past output
               call     trim           ; trim any whitespace
               mov      rd,buffer2     ; point to buffer
library_lp:    lda      rf             ; get byte from input
               lbz      library_dn     ; jump if terminator
               call7    cmp            ; check for space
               db       ' '
               lbdf     library_dn     ; jump if space
               str      rd             ; otherwise store intput outname
               inc      rd
               lbr      library_lp     ; loop until done
library_dn:    ldi      0              ; need a terminator
               str      rd
               mov      rf,buffer2     ; point to library name
               call     addlibrary     ; and add library ot list
               lbr      loop           ; process next line

; +++++++++++++++++++++++
; +++++ Check 'add' +++++
; +++++++++++++++++++++++
not_library:   mov      rf,buffer      ; point to input buffer
               mov      rd,lbladd      ; point to label
               mov      rc,4
               call     strncasecmp    ; compare strings
               lbnf     loop           ; ignore unknown line
               mov      rf,buffer+4    ; move past output
               call     trim           ; trim any whitespace
               mov      rd,buffer2     ; point to buffer
add_lp:        lda      rf             ; get byte from input
               lbz      add_dn         ; jump if terminator
               call7    cmp            ; check for space
               db       ' '
               lbdf     add_dn         ; jump if space
               str      rd             ; otherwise store intput outname
               inc      rd
               lbr      add_lp         ; loop until done
add_dn:        ldi      0              ; need a terminator
               str      rd
               mov      rf,buffer2     ; point to library name
               call     loadfile       ; and load file
               lbdf     fileerr        ; jump if error
               call7    load_rf        ; get object file count
               dw       objcount
               inc      rf             ; increment it
               call7    store_rf       ; and put it back
               dw       objcount
               lbr      loop           ; process next line

eof:           mov      rd,ctrlfildes  ; point to fildes for control file
               call     o_close        ; and close it
               rtn                     ; then return to caller


readln:        mov      rf,buffer      ; where to put line
               ldi      0              ; character counter
               plo      rc
readln_lp:     push     rf             ; save buffer position
               glo      rc             ; and count
               stxd
               mov      rf,buffer2     ; point to buffer2
               mov      rd,ctrlfildes  ; point to fildes
               mov      rc,1           ; read 1 byte
               call     o_read         ; call Elf/OS to read byte
               lbdf     cfileerr       ; jump if read error occurred
               mov      r7,microint    ; reset R7
               glo      rc             ; were bytes read
               lbz      readln_eof     ; jump if not
               irx                     ; recover saved data
               ldx
               plo      rc
               pop      rf
               mov      ra,buffer2     ; get read byte
               ldn      ra
               call7    cmp            ; is it a line ending character
               db       10
               lbdf     readln_le      ; jump if so
               call7    cmp            ; is it a line ending character
               db       13
               lbdf     readln_le      ; jump if so
               str      rf             ; otherwise store into line
               inc      rf
               inc      rc             ; increment character count
               lbr      readln_lp      ; loop for more
readln_le:     glo      rc             ; have bytes been read
               lbz      readln_lp      ; ignore line ending if no
               ldi      0              ; write terminator
               str      rf
               adi      0              ; signal line read
               rtn                     ; and return
readln_eof:    irx                     ; remove items from stack 
               irx
               irx
               smi      0              ; signal end of file
               rtn                     ; and return

cfileerr:      call     o_inmsg        ; display error message
               db       'Error: Error reading control file',10,13,0
               lbr      o_wrmboot      ; return to Elf/OS

lbladd:        db       'add ',0
lblbig:        db       'big',0
lblbinary:     db       'binary',0
lblelfos:      db       'elfos',0
lblintel:      db       'intel',0
lbllibrary:    db       'library ',0
lbllittle:     db       'little',0
lblmode:       db       'mode ',0
lbloutput:     db       'output ',0
lblrcs:        db       'rcs',0

               endp
