#include       macros.inc
#include       ../kernel.inc

; ****************************************************
; ***** load object file                         *****
; ***** RF - Pointer to filename                 *****
; ***** Returns: DF=1 - Error occured            *****
; *****          DF=0 - Success                  *****
; ****************************************************
               proc     loadfile

               extrn    address;
               extrn    addlibrary
               extrn    addreference
               extrn    addressmode
               extrn    addsymbol
               extrn    buffer
               extrn    buffer2
               extrn    checkreq
               extrn    crlf
               extrn    fildes1
               extrn    findreference
               extrn    findrequire
               extrn    findsymbol
               extrn    gethex
               extrn    highest
               extrn    inproc
               extrn    libscan
               extrn    load_d
               extrn    load_ra
               extrn    load_rb
               extrn    load_rd
               extrn    loadmodule
               extrn    lowest
               extrn    microint
               extrn    offset
               extrn    outhex4
               extrn    readln
               extrn    readlnrst
               extrn    readmap
               extrn    readmem
               extrn    readmemb
               extrn    set_byte
               extrn    set_word
               extrn    startaddress
               extrn    strncmp
               extrn    store_ra
               extrn    store_rd
               extrn    trim
               extrn    writemap
               extrn    writemem
               extrn    writememb

; ++++++++++++++++++++++
; +++++ Do startup +++++
; ++++++++++++++++++++++
               push     rf             ; save filename
               call7    load_d         ; see if scanning a library
               dw       libscan
               lbnz     noprint        ; jump if scanning a library
               call     o_inmsg        ; display filename
               db       'Linking: ',0
               pop      rf             ; recover filename
               dec      r2             ; keep on stack
               dec      r2
               call     o_msg          ; display filename
               call     crlf           ; display cr/lf
noprint:       call7    set_byte       ; clear inproc
               dw       inproc
               db       0
               call7    set_word       ; cler offset
               dw       offset
               dw       0
               call     readlnrst      ; reset readln
               pop      rf             ; recover filename
               dec      r2             ; keep on stack as well
               dec      r2
               mov      rd,fildes1     ; point to fildes
               mov      r7,0           ; no special flags
               call     o_open         ; call Elf/OS to open file
               mov      r7,microint    ; reset R7
               lbnf     opened         ; jump if no error occured
               call     o_inmsg        ; display error
               db       'Could not open input file: ',0
               pop      rf             ; recover filename
               call     o_msg          ; display it
               call     crlf           ; display crlf
               smi      0              ; indicate file error
               rtn                     ; return to caller
opened:        irx                     ; remove RF from stack
               irx

; ++++++++++++++++++++++++++
; +++++ Main file loop +++++
; ++++++++++++++++++++++++++
loop:          mov      rf,buffer      ; where to read line
               mov      rd,fildes1     ; pointer to input fildes
               call     readln         ; read next line of input
               lbdf     eof            ; jump if end of file found
               mov      rf,buffer
               call7    load_d         ; see if load module is on
               dw       loadmodule
               lbz      checkproc      ; procs only if loadmodule is false
               
; ++++++++++++++++++++++++++
; +++++ Check for .big +++++
; ++++++++++++++++++++++++++
fullscan:      mov      rf,buffer      ; point to input
               ldn      rf             ; see if . directive
               smi      '.'
               lbnz     next_5         ; jump if not directive
               mov      rd,lblbig      ; point to .big text
               mov      rc,4           ; 4 characters to compare
               call     strncmp        ; perform cmpare
               lbnf     next_1         ; nope, try next
               call7    set_byte       ; set address mode to big endian
               dw       addressmode
               db       'B'
               lbr      loop           ; then read next line

; +++++++++++++++++++++++++++++
; +++++ Check for .little +++++
; +++++++++++++++++++++++++++++
next_1:        mov      rf,buffer      ; point to input
               mov      rd,lbllittle   ; point to .little text
               mov      rc,7           ; 4 characters to compare
               call     strncmp        ; perform cmpare
               lbnf     next_2         ; nope, try next
               call7    set_byte       ; set address mode to big endian
               dw       addressmode
               db       'L'
               lbr      loop           ; then read next line

; ++++++++++++++++++++++++++++
; +++++ Check for .align +++++
; ++++++++++++++++++++++++++++
next_2:        mov      rf,buffer      ; point to input
               mov      rd,lblalign    ; point to .align text
               mov      rc,7           ; 4 characters to compare
               call     strncmp        ; perform cmpare
               lbnf     next_3         ; nope, try next
               call     trim           ; move past any white space
               push     rf             ; need to keep buffer position
; ------------------------
; ----- Check 'word' -----
; ------------------------
               mov      rd,lblword     ; check for 'word'
               mov      rc,4           ; 4 bytes to compare
               call     strncmp        ; check
               lbnf     not_2_1        ; jump if not
               irx                     ; remove rf from stack
               irx
               call7    load_ra        ; retrieve offset
               dw       offset
               inc      r1             ; add 1
               glo      ra             ; and with FFFE
               ani      0feh
               plo      ra
               call7    store_ra       ; write new offset
               lbr      loop           ; then next line

; -------------------------
; ----- Check 'dword' -----
; -------------------------
not_2_1:       pop      rf             ; recover string
               dec      r2             ; and keep on stack
               dec      r2
               mov      rd,lbldword    ; check for 'dword'
               mov      rc,5           ; 5 bytes to compare
               call     strncmp        ; check
               lbnf     not_2_2        ; jump if not
               irx                     ; remove rf from stack
               irx
               call7    load_ra        ; retrieve offset
               dw       offset
               inc      ra             ; add 3
               inc      ra
               inc      ra
               glo      ra             ; and with FFFC
               ani      0fch
               plo      ra
               call7    store_ra       ; write new offset
               lbr      loop           ; then next line

; -------------------------
; ----- Check 'qword' -----
; -------------------------
not_2_2:       pop      rf             ; recover string
               dec      r2             ; and keep on stack
               dec      r2
               mov      rd,lblqword    ; check for 'qword'
               mov      rc,5           ; 5 bytes to compare
               call     strncmp        ; check
               lbnf     not_2_3        ; jump if not
               irx                     ; remove rf from stack
               irx
               call7    load_ra        ; retrieve offset
               dw       offset
               glo      ra             ; add 7
               adi      7
               plo      ra
               ghi      ra
               adci     0
               phi      ra
               glo      ra             ; and with FFF8
               ani      0f8h
               plo      ra
               call7    store_ra       ; write new offset
               lbr      loop           ; then next line

; ------------------------
; ----- Check 'para' -----
; ------------------------
not_2_3:       pop      rf             ; recover string
               dec      r2             ; and keep on stack
               dec      r2
               mov      rd,lblpara     ; check for 'para'
               mov      rc,4           ; 5 bytes to compare
               call     strncmp        ; check
               lbnf     not_2_4        ; jump if not
               irx                     ; remove rf from stack
               irx
               call7    load_ra        ; retrieve offset
               dw       offset
               glo      ra             ; add 15
               adi      15
               plo      ra
               ghi      ra
               adci     0
               phi      ra
               glo      ra             ; and with FFF0
               ani      0f0h
               plo      ra
               call7    store_ra       ; write new offset
               lbr      loop           ; then next line

; ----------------------
; ----- Check '32' -----
; ----------------------
not_2_4:       pop      rf             ; recover string
               dec      r2             ; and keep on stack
               dec      r2
               mov      rd,lbl32       ; check for '32'
               mov      rc,2           ; 2 bytes to compare
               call     strncmp        ; check
               lbnf     not_2_5        ; jump if not
               irx                     ; remove rf from stack
               irx
               call7    load_ra        ; retrieve offset
               dw       offset
               glo      ra             ; add 31
               adi      31
               plo      ra
               ghi      ra
               adci     0
               phi      ra
               glo      ra             ; and with FFE0
               ani      0e0h
               plo      ra
               call7    store_ra       ; write new offset
               lbr      loop           ; then next line

; ----------------------
; ----- Check '64' -----
; ----------------------
not_2_5:       pop      rf             ; recover string
               dec      r2             ; and keep on stack
               dec      r2
               mov      rd,lbl64       ; check for '64'
               mov      rc,2           ; 2 bytes to compare
               call     strncmp        ; check
               lbnf     not_2_6        ; jump if not
               irx                     ; remove rf from stack
               irx
               call7    load_ra        ; retrieve offset
               dw       offset
               glo      ra             ; add 63
               adi      63
               plo      ra
               ghi      ra
               adci     0
               phi      ra
               glo      ra             ; and with FFC0
               ani      0c0h
               plo      ra
               call7    store_ra       ; write new offset
               lbr      loop           ; then next line

; -----------------------
; ----- Check '128' -----
; -----------------------
not_2_6:       pop      rf             ; recover string
               dec      r2             ; and keep on stack
               dec      r2
               mov      rd,lbl128      ; check for '128'
               mov      rc,3           ; 3 bytes to compare
               call     strncmp        ; check
               lbnf     not_2_7        ; jump if not
               irx                     ; remove rf from stack
               irx
               call7    load_ra        ; retrieve offset
               dw       offset
               glo      ra             ; add 127
               adi      127
               plo      ra
               ghi      ra
               adci     0
               phi      ra
               glo      ra             ; and with FF80
               ani      080h
               plo      ra
               call7    store_ra       ; write new offset
               lbr      loop           ; then next line

; -----------------------
; ----- Check 'page' -----
; -----------------------
not_2_7:       pop      rf             ; recover string
               dec      r2             ; and keep on stack
               dec      r2
               mov      rd,lblpage     ; check for 'page'
               mov      rc,4           ; 4 bytes to compare
               call     strncmp        ; check
               lbnf     not_2_8        ; jump if not
               irx                     ; remove rf from stack
               irx
               call7    load_ra        ; retrieve offset
               dw       offset
               glo      ra             ; add 255
               adi      255
               plo      ra
               ghi      ra
               adci     0
               phi      ra
               ldi      0              ; and with FF00
               plo      ra
               call7    store_ra       ; write new offset
               lbr      loop           ; then next line

not_2_8:       call     o_inmsg        ; display error
               db       'Invalid .align: ',0
               pop      rf             ; recover string
               call     o_msg          ; display it
               smi      0              ; indicate error
               rtn                     ; and return to caller

; ++++++++++++++++++++++++++++++
; +++++ Check for .library +++++
; ++++++++++++++++++++++++++++++
next_3:        mov      rf,buffer      ; point to input
               mov      rd,lbllibrary  ; point to .library text
               mov      rc,9           ; 9 characters to compare
               call     strncmp        ; perform cmpare
               lbnf     next_4         ; nope, try next
               call     trim           ; move past any white space
               call     addlibrary     ; add library to list
               lbr      loop           ; then next line

; +++++++++++++++++++++++++++++++
; +++++ Check for .requires +++++
; +++++++++++++++++++++++++++++++
next_4:        mov      rf,buffer      ; point to input
               mov      rd,lblrequires ; point to .requires text
               mov      rc,10          ; 10 characters to compare
               call     strncmp        ; perform cmpare
               lbnf     next_5         ; nope, try next
               call     trim           ; move past any white space
               call     checkreq       ; does requires already exist
               lbdf     loop           ; next line if so
               mov      rd,0ffffh      ; no value for requres reference
               ldi      'R'            ; type is 'R'equires
               call     addreference   ; add reference to list
               lbr      loop           ; then next line

; ++++++++++++++++++++++++++++++
; +++++ Check for : marker +++++
; ++++++++++++++++++++++++++++++
next_5:        ldn      rf             ; get first character of line
               smi      ':'            ; check for data marker
               lbnz     next_6         ; jump if not
               call7    load_d         ; need to see if in load module
               dw       loadmodule
               lbz      next_6         ; jump if not
               inc      rf             ; move past marker
               call     gethex         ; get address
               mov      ra,rd          ; move to RA
               call7    load_d         ; need to see if in PROC
               dw       inproc
               lbz      dataloop       ; jump if not in proc
               call     addoffset      ; add in PROC offset
dataloop:      call     trim           ; move past any white space
               ldn      rf             ; check for line end
               lbz      loop           ; on to next line if done
               call     gethex         ; get next byte value
               glo      rd             ; get low of value
               call     writememb      ; write byte to memory
               call     readmap        ; see if address is used
               lbnf     notused        ; jump if not collision
               push     rf             ; save registers
               push     ra
               call     o_inmsg        ; display error
               db       'Error: Collision at ',0
               mov      r9,buffer2     ; point to temp buffer
               call     outhex4        ; convert address
               ldi      0              ; terminate ascii address
               str      r9
               mov      rf,buffer2     ; point to ascii conversion
               call     o_msg          ; and display it
               call     crlf           ; display crlf
               pop      ra             ; recover registers
               pop      rf
notused:       call     writemap       ; mark address as used
               call7    load_rd        ; get lowest address
               dw       lowest
               glo      rd             ; subtract address from lowest
               str      r2
               glo      ra
               sm
               ghi      rd
               str      r2
               ghi      ra
               smb
               lbdf     notlowest      ; jump if not lowest address
               call7    store_ra       ; write new lowest address
               dw       lowest
notlowest:     call7    load_rd        ; get highest address
               dw       highest
               glo      ra             ; subtract highest from address
               str      r2
               glo      rd
               sm
               ghi      ra
               str      r2
               ghi      rd
               smb
               lbdf     nothighest     ; jump if not highest address
               call7    store_ra       ; write new highest address
               dw       highest
nothighest:    inc      ra             ; increment address
               call7    store_ra       ; write new address
               dw       address
               lbr      dataloop       ; loop until done with line

; ++++++++++++++++++++++++++++++
; +++++ Check for @ marker +++++
; ++++++++++++++++++++++++++++++
next_6:        ldn      rf             ; get first character of line
               smi      '@'            ; check for exec address marker
               lbnz     next_7         ; jump if not
               inc      rf
               call     gethex         ; get address
               call7    store_rd       ; write start address
               dw       startaddress
               lbr      loop           ; then process next line

; ++++++++++++++++++++++++++++++
; +++++ Check for + marker +++++
; ++++++++++++++++++++++++++++++
next_7:        ldn      rf             ; get first character of line
               smi      '+'            ; check for add offset marker
               lbnz     next_8         ; jump if not
               inc      rf
               call     gethex         ; get address
               mov      ra,rd          ; move address to RA
               call     addoffset      ; add current offset
               call     readmem        ; read word at address
               call7    load_rb        ; get offset
               dw       offset
               glo      rb             ; add offset to memory word
               str      r2
               glo      rd
               add
               plo      rd
               ghi      rb
               str      r2
               ghi      rd
               adc
               phi      rd
               call     writemem       ; write word back to memory
               lbr      loop           ; then process next line

; ++++++++++++++++++++++++++++++
; +++++ Check for ^ marker +++++
; ++++++++++++++++++++++++++++++
next_8:        ldn      rf             ; get first character of line
               smi      '^'            ; check for add high byte offset marker
               lbnz     next_9         ; jump if not
               inc      rf
               call     gethex         ; get address
               mov      ra,rd          ; move address to RA
               call     addoffset      ; add current offset
               call     readmemb       ; read byte at address
               phi      rd             ; set RD to value
               ldi      0              ; clear low byte
               plo      rd
               call7    load_rb        ; get offset
               dw       offset
               glo      rb             ; add offset to memory word
               str      r2
               glo      rd
               add
               plo      rd
               ghi      rb
               str      r2
               ghi      rd
               adc
               phi      rd
               push     rd             ; save this for now
               call     trim           ; move past any spaces
               call     gethex         ; get lsb offset if it exists
               pop      rb             ; recover address
               glo      rb             ; add with lsb offset
               str      r2
               glo      rd
               add
               ghi      rb
               str      r2
               ghi      rd
               adc
               call     writememb      ; write value back to memory
               lbr      loop           ; then process next line

; ++++++++++++++++++++++++++++++
; +++++ Check for v marker +++++
; ++++++++++++++++++++++++++++++
next_9:        ldn      rf             ; get first character of line
               smi      'v'            ; check for add low byte offset marker
               lbnz     next_10        ; jump if not
               inc      rf
               call     gethex         ; get address
               mov      ra,rd          ; move address to RA
               call     addoffset      ; add current offset
               call     readmemb       ; read byte at address
               plo      rd             ; set RD to value
               ldi      0              ; clear low byte
               phi      rd
               call7    load_rb        ; get offset
               dw       offset
               glo      rb             ; add offset to memory word
               str      r2
               glo      rd
               add
               call     writememb      ; write value back to memory
               lbr      loop           ; then process next line

; ++++++++++++++++++++++++++++++
; +++++ Check for = marker +++++
; ++++++++++++++++++++++++++++++
next_10:       ldn      rf             ; get first character of line
               smi      '='            ; check for public symbol marker
               lbnz     next_11        ; jump if not
               inc      rf
               mov      rd,buffer2     ; need to copy symbol name
loop_10:       lda      rf             ; get byte from name
               str      rd             ; write to buffer
               inc      rd
               smi      32             ; was a space written
               lbnz     loop_10        ; loop until a space encountered
               dec      rd             ; terminate string
               ldi      0
               str      rd
               call     trim           ; move past any spaces in line
               push     rf             ; save line position
               mov      rf,buffer2     ; point to symbol
               call     findsymbol     ; see if symbol exists
               pop      rf             ; recover line position
               lbdf     exists_10      ; jump if the symbol exists
               call     gethex         ; get value of symbol
               call7    load_d         ; need to see if in PROC
               dw       inproc
               lbz      noproc_10      ; jump if not
               call7    load_rb        ; get current offset
               dw       offset
               glo      rb             ; add offset to value
               str      r2
               glo      rd
               add
               plo      rd
               ghi      rb
               str      r2
               ghi      rd
               adc
               phi      rd
noproc_10:     mov      rf,buffer2     ; point to buffer
               call     addsymbol      ; add public symbol
               lbr      loop           ; then on to next line
exists_10:     call     o_inmsg        ; print error message
               db       'Error: Duplicate symbol: ',0
               mov      rf,buffer2     ; point to symbol name
               call     o_msg          ; display it
               call     crlf           ; followed by cr/lf
               smi      0              ; indicate error occured
               rtn                     ; and return to caller

; ++++++++++++++++++++++++++++++
; +++++ Check for ? marker +++++
; ++++++++++++++++++++++++++++++
next_11:       ldn      rf             ; get first character of line
               smi      '?'            ; check for unknown symbol marker
               lbnz     next_12        ; jump if not
               inc      rf             ; move past '?'
               call7    load_d         ; need to see if in module
               dw       loadmodule
               lbz      next_12        ; jump if not
               mov      rd,buffer2     ; need to copy symbol name
loop_11:       lda      rf             ; get byte from name
               str      rd             ; write to buffer
               inc      rd
               smi      32             ; was a space written
               lbnz     loop_11        ; loop until a space encountered
               dec      rd             ; terminate string
               ldi      0
               str      rd
               call     trim           ; move past any spaces in line
               call     gethex         ; get address for reference
               call7    load_d         ; need to see if in PROC
               dw       inproc
               lbz      noproc_11      ; jump if not
               call7    load_rb        ; get current offset
               dw       offset
               glo      rb             ; add offset to value
               str      r2
               glo      rd
               add
               plo      rd
               ghi      rb
               str      r2
               ghi      rd
               adc
               phi      rd
noproc_11:     ldi      0              ; no lsb offset
               plo      rb
               mov      rf,buffer2     ; point to reference name
               ldi      'W'            ; reference type is word
               call     addreference   ; add to reference list
               lbr      loop           ; then process next line

; ++++++++++++++++++++++++++++++
; +++++ Check for / marker +++++
; ++++++++++++++++++++++++++++++
next_12:       ldn      rf             ; get first character of line
               smi      '/'            ; check for unknown high symbol marker
               lbnz     next_13        ; jump if not
               inc      rf             ; move past '/'
               call7    load_d         ; need to see if in module
               dw       loadmodule
               lbz      next_13        ; jump if not
               mov      rd,buffer2     ; need to copy symbol name
loop_12:       lda      rf             ; get byte from name
               str      rd             ; write to buffer
               inc      rd
               smi      32             ; was a space written
               lbnz     loop_12        ; loop until a space encountered
               dec      rd             ; terminate string
               ldi      0
               str      rd
               call     trim           ; move past any spaces in line
               call     gethex         ; get address for reference
               call7    load_d         ; need to see if in PROC
               dw       inproc
               lbz      noproc_12      ; jump if not
               call7    load_rb        ; get current offset
               dw       offset
               glo      rb             ; add offset to value
               str      r2
               glo      rd
               add
               plo      rd
               ghi      rb
               str      r2
               ghi      rd
               adc
               phi      rd
noproc_12:     mov      rf,buffer2     ; point to reference name
               ldi      0              ; TODO need real lsb offset
               plo      rb
               ldi      'H'            ; reference type is high byte
               call     addreference   ; add to reference list
               lbr      loop           ; then process next line

; ++++++++++++++++++++++++++++++
; +++++ Check for \ marker +++++
; ++++++++++++++++++++++++++++++
next_13:       ldn      rf             ; get first character of line
               smi      '\'            ; check for unknown high symbol marker
               lbnz     checkproc      ; jump if not
               inc      rf             ; move past '\'
               call7    load_d         ; need to see if in module
               dw       loadmodule
               lbz      checkproc      ; jump if not
               mov      rd,buffer2     ; need to copy symbol name
loop_13:       lda      rf             ; get byte from name
               str      rd             ; write to buffer
               inc      rd
               smi      32             ; was a space written
               lbnz     loop_13        ; loop until a space encountered
               dec      rd             ; terminate string
               ldi      0
               str      rd
               call     trim           ; move past any spaces in line
               call     gethex         ; get address for reference
               call7    load_d         ; need to see if in PROC
               dw       inproc
               lbz      noproc_13      ; jump if not
               call7    load_rb        ; get current offset
               dw       offset
               glo      rb             ; add offset to value
               str      r2
               glo      rd
               add
               plo      rd
               ghi      rb
               str      r2
               ghi      rd
               adc
               phi      rd
noproc_13:     mov      rf,buffer2     ; point to reference name
               ldi      0              ; no lsb offset
               plo      rb
               ldi      'L'            ; reference type is low byte
               call     addreference   ; add to reference list
               lbr      loop           ; then process next line

; ++++++++++++++++++++++++++++++
; +++++ Check for { marker +++++
; ++++++++++++++++++++++++++++++
checkproc:     ldn      rf             ; get first character of line
               smi      '{'            ; check for beginning of proc marker
               lbnz     next_15        ; jump if not
               inc      rf             ; move past '{'
               mov      rd,buffer2     ; need to copy symbol name
loop_14:       lda      rf             ; get byte from name
               str      rd             ; write to buffer
               inc      rd
               lbz      term_14        ; jump if terminator encountered
               smi      32             ; was a space written
               lbnz     loop_14        ; loop until a space encountered
term_14:       dec      rd             ; terminate string
               ldi      0
               str      rd
               call7    load_d         ; need to see if scanning a library
               dw       libscan
               lbz      nolib_14       ; jump if not a library can
               mov      rf,buffer2     ; point to symbol
               call     findreference  ; see if reference exists
               lbnf     noref_14       ; jump if reference was not found
linkproc:      call7    set_byte       ; set load module true
               dw       loadmodule
               db       0ffh
               call     o_inmsg        ; display message
               db       'Linking ',0
               mov      rf,buffer2
               call     o_msg
               call     o_inmsg
               db       ' from library',10,13,0
               lbr      nolib_14       ; continue processing
noref_14:      mov      rf,buffer2     ; point to symbol
               call     findrequire    ; get for a requires
               lbnf     loop           ; if none, ignore this proc
               lbr      linkproc       ; will link this proc
nolib_14:      call7    load_d         ; need to see if load module is true
               dw       loadmodule
               lbz      loop           ; do not process if not
               mov      rf,buffer2     ; point to symbol
               call     findsymbol     ; see if symbol is defined
               lbnf     good_14        ; jump if symbol is undefined
               call     o_inmsg        ; display error
               db       'Error: Duplicate symbol: ',0
               mov      rf,buffer2     ; point to symbol
               call     o_msg
               call     crlf           ; display crlf
               smi      0              ; indicate error
               rtn                     ; and return
good_14:       call7    load_rd        ; get last address written
               dw       address
               call7    store_rd       ; store into offset
               dw       offset
               mov      rf,buffer2     ; point to symbol name
               call     addsymbol      ; add proc symbol
               call7    set_byte       ; mark in proc
               dw       inproc
               db       0ffh
               lbr      loop           ; then on to next line

; ++++++++++++++++++++++++++++++
; +++++ Check for } marker +++++
; ++++++++++++++++++++++++++++++
next_15:       ldn      rf             ; get first character of line
               smi      '}'            ; check for end of proc marker
               lbnz     next_16        ; jump if not
               call7    set_byte       ; clear inproc
               dw       inproc
               db       0
               call7    set_word       ; clear offset
               dw       offset
               dw       0
               call7    load_d         ; need to see if scanning library
               dw       libscan
               lbz      loop           ; process next line if not
               call7    set_byte       ; need to clear load module
               dw       loadmodule
               db       0
               lbr      loop           ; then process next line

; ++++++++++++++++++++++++++++++++++++++
; +++++ Unknown marker encountered +++++
; ++++++++++++++++++++++++++++++++++++++
next_16:       lbr      loop           ; ignore unknown lines
               call     o_inmsg        ; print error message
               db       'Error: Unknown marker: ',0
               ldn      rf             ; get marker
               call     o_type         ; output it
               call     crlf           ; output cr/lf
               smi      0              ; indicate error
               rtn                     ; and return to caller

; +++++++++++++++++++++++++++++++++++++++++
; +++++ File has been completely read +++++
; +++++++++++++++++++++++++++++++++++++++++
eof:           mov      rd,fildes1     ; point to fildes
               call     o_close        ; close the file
               adi      0              ; indicate successful read
               rtn                     ; and return to caller

addoffset:     call7    load_rd        ; retrieve offset
               dw       offset
               glo      rd             ; add offset to address
               str      r2
               glo      ra
               add
               plo      ra
               ghi      rd
               str      r2
               ghi      ra
               adc
               phi      ra             ; RA now has adjusted address
               rtn                     ; return to caller

lbl128:       db        '128'
lbl32:        db        '32'
lbl64:        db        '64'
lblalign:     db        '.align '
lblbig:       db        '.big'
lbldword:     db        'dword'
lbllibrary:   db        '.library'
lbllittle:    db        '.little'
lblpage:      db        'page'
lblpara:      db        'para'
lblqword:     db        'qword'
lblrequires:  db        '.requires'
lblword:      db        'word'

               endp

