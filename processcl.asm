#include       macros.inc
#include       ../kernel.inc

; *******************************
; ***** Read virtual memory *****
; ***** RA - VRAM address   *****
; ***** Returns: RD - value *****
; *******************************
               proc     processcl

               extrn    addlibrary
               extrn    addressmode
               extrn    buffer
               extrn    buffer2
               extrn    load_rf
               extrn    loadfile
               extrn    objcount
               extrn    outmode
               extrn    outname
               extrn    set_byte
               extrn    showsymbols
               extrn    store_rf

loop:          lda      ra             ; move past any spaces
               smi      32             ; check for space
               lbz      loop
               dec      ra             ; move back to non-space
               ldn      ra             ; get byte from cl
               lbz      done           ; jump if done
               smi      '-'            ; check for switch
               lbz      switches       ; jump if so
               ldn      ra             ; recover byte
               smi      '@'            ; check for control file
               lbz      control        ; jump if control file
; ++++++++++++++++++++++++++++++++++++++++++++++
; +++++ if no options, then process a file +++++
; ++++++++++++++++++++++++++++++++++++++++++++++
               mov      rf,buffer      ; otherwise file to be processed
               ldi      0              ; character counter
               plo      rc
filenmlp:      lda      ra             ; get next byte from CL
               plo      re             ; keep a copy
               lbz      filenmdn       ; jump if terminator found
               smi      32             ; check for space
               lbz      filenmdn       ; name is done with a space
               glo      re             ; recover character
               str      rf             ; write to buffer
               inc      rf
               inc      rc             ; increment character count
               lbr      filenmlp       ; loop until name copied
filenmdn:      ldi      0              ; terminate name
               str      rf
               mov      rb,outname     ; see if an outname exists
               ldn      rb             ; retrieve first byte
               lbnz     nooutname      ; jump if no name needed
               mov      rf,buffer      ; use first object name as outname
               mov      rd,outname
outnmloop:     lda      rf             ; copy byte from object name
               str      rd             ; into outname
               inc      rd
               lbnz     outnmloop      ; loop until terminator copied
nooutname:     push     ra             ; save CL position
               mov      rf,buffer      ; point to filename
               call     loadfile       ; load the file
               pop      ra             ; recover CL position
               lbdf     fileerr        ; jump if error occurred
               call7    load_rf        ; get object file count
               dw       objcount
               inc      rf             ; increment it
               call7    store_rf       ; and put it back
               dw       objcount
               lbr      loop           ; process any additional args
fileerr:       call     o_inmsg        ; display error
               db       'Errors during link.  Aborting output',10,13,0
               lbr      o_wrmboot      ; return to Elf/OS

control:


; ***************************************
; ***** Process command line switch *****
; ***************************************
switches:      inc      ra             ; move past -
               lda      ra             ; get switch
               plo      re             ; keep a copy
; ++++++++++++++
; +++++ -e +++++
; ++++++++++++++
               smi      'e'            ; check for -e
               lbnz     no_1           ; jump if not
               call7    set_byte       ; set output mode to Elf/OS
               dw       outmode
               db       2
               lbr      loop           ; process next argument

; ++++++++++++++
; +++++ -i +++++
; ++++++++++++++
no_1:          glo      re             ; recover byte
               smi      'i'            ; check for -i
               lbnz     no_2           ; jump if not
               call7    set_byte       ; set output mode to Intel hex
               dw       outmode
               db       5
               lbr      loop           ; process next argument

; ++++++++++++++
; +++++ -h +++++
; ++++++++++++++
no_2:          glo      re             ; recover byte
               smi      'h'            ; check for -h
               lbnz     no_3           ; jump if not
               call7    set_byte       ; set output mode to Intel hex
               dw       outmode
               db       4
               lbr      loop           ; process next argument

; ++++++++++++++
; +++++ -b +++++
; ++++++++++++++
no_3:          glo      re             ; recover byte
               smi      'b'            ; check for -b
               lbnz     no_4           ; jump if not
               ldn      ra             ; need next byte
               smi      'e'            ; is it e?
               lbz      no_3a          ; jump if so
               call7    set_byte       ; set output mode to Intel hex
               dw       outmode
               db       1
               lbr      loop           ; process next argument
no_3a:         inc      ra             ; move past the 'e'
               call7    set_byte       ; set big endian mode
               dw       addressmode
               db       'B'
               lbr      loop           ; then to next arg

; ++++++++++++++
; +++++ -s +++++
; ++++++++++++++
no_4:          glo      re             ; recover byte
               smi      's'            ; check for -s
               lbnz     no_5           ; jump if not
               call7    set_byte       ; set show symbols true
               dw       showsymbols
               db       0ffh
               lbr      loop           ; process next argument

; ++++++++++++++
; +++++ -l +++++
; ++++++++++++++
no_5:          glo      re             ; recover byte
               smi      'l'            ; check for -l
               lbnz     no_6           ; jump if not
               ldn      ra             ; need next byte
               smi      'e'            ; is it e?
               lbz      no_5a          ; jump if so
lib_loop:      lda      ra             ; move past any spaces
               smi      32
               lbnz     lib_loop
               dec      ra             ; move back to non-space
               mov      rf,buffer2     ; point to buffer
               ldi      0              ; clear character count
               plo      rc
lib_nmlp:      lda      ra             ; get byte from cl
               lbz      lib_nmdn       ; jump if terminator found
               smi      32             ; check for space
               lbz      lib_nmdn       ; done with name if space
               glo      re             ; recover byte
               str      rf             ; store into buffer
               inc      rf
               inc      rc             ; increment character count
               lbr      lib_nmlp       ; loop until name retrieved
lib_nmdn:      glo      rc             ; where characters found
               lbz      loop           ; ignore -l if no name found
               ldi      0              ; terminate name
               str      rf
               push     ra             ; save cl position
               mov      rf,buffer2     ; point to name
               call     addlibrary     ; add library to list
               pop      ra             ; recover ra
               lbr      loop           ; process next arg
no_5a:         inc      ra             ; move past the 'e'
               call7    set_byte       ; set little endian mode
               dw       addressmode
               db       'L'
               lbr      loop           ; process next arg

; ++++++++++++++
; +++++ -o +++++
; ++++++++++++++
no_6:          glo      re             ; recover byte
               smi      'o'            ; check for -l
               lbnz     loop           ; process next arg
obj_loop:      lda      ra             ; move past any spaces
               smi      32
               lbnz     obj_loop
               dec      ra             ; move back to non-space
               mov      rf,outname     ; point to output name
               ldi      0              ; clear character count
               plo      rc
obj_nmlp:      lda      ra             ; get byte from cl
               lbz      obj_nmdn       ; jump if terminator found
               smi      32             ; check for space
               lbz      obj_nmdn       ; done with name if space
               glo      re             ; recover byte
               str      rf             ; store into buffer
               inc      rf
               inc      rc             ; increment character count
               lbr      obj_nmlp       ; loop until name retrieved
obj_nmdn:      glo      rc             ; where characters found
               lbz      loop           ; ignore -l if no name found
               ldi      0              ; terminate name
               str      rf
               lbr      loop           ; then process next arg

done:          rtn

               endp
