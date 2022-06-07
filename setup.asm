#include       macros.inc
#include       ../kernel.inc

; ****************************************************
; ***** Convert RA to 4 hex digits               *****
; ***** RF - Where to put                        *****
; ***** Returns: RF   - incremented              *****
; ****************************************************
               proc     setup

               extrn    address
               extrn    addressmode
               extrn    buffer
               extrn    dta1
               extrn    fildes1
               extrn    freemem
               extrn    highest
               extrn    libraries
               extrn    librariesend
               extrn    libscan
               extrn    libtable
               extrn    load_rf
               extrn    loadmodule
               extrn    lowest
               extrn    map
               extrn    mapfildes
               extrn    mapopenerr
               extrn    mapwrterr
               extrn    microint
               extrn    objcount
               extrn    outhex2
               extrn    outmode
               extrn    outname
               extrn    references
               extrn    referencesend
               extrn    set_byte
               extrn    set_word
               extrn    showsymbols
               extrn    startaddress
               extrn    store_rf
               extrn    symbols
               extrn    vram
               extrn    vramfildes
               extrn    vramopenerr
               extrn    vramwrterr
          

               mov      r7,microint    ; setup micro interpreter
               call7    set_word       ; setup lowest address
               dw       lowest
               dw       0ffffh
               call7    set_word       ; setup highest address
               dw       highest
               dw       00000h
               call7    set_word       ; setup start address
               dw       startaddress
               dw       0ffffh
               call7    set_byte       ; set address mode
               dw       addressmode
               db       'L'
               call7    set_byte       ; set output mode to binary
               dw       outmode
               db       1
               call7    set_word       ; set load address to 0
               dw       address
               dw       0
               call7    set_byte       ; clear show symbols flag
               dw       showsymbols
               db       0
               call7    set_byte       ; set libscan to false
               dw       libscan
               db       0
               call7    set_byte       ; set loadmodule to true
               dw       loadmodule
               db       0ffh
               call7    set_word       ; clear object file counter
               dw       objcount
               dw       0
               call7    set_byte       ; null outname
               dw       outname
               db       0
               call7    load_rf        ; get highest address from kernel
               dw       k_himem
               ldi      0              ; place terminator in symbol table
               str      rf
               call7    store_rf       ; write symbol table end address
               dw       symbols
               mov      rf,freemem+1   ; free memory address
               ldi      0              ; write terminator to references
               str      rf
               call7    store_rf       ; write reference table address
               dw       references
               call7    store_rf       ; and reference table end
               dw       referencesend
               mov      rf,libtable    ; address of library table
               ldi      0              ; write terminator
               str      rf
               call7    store_rf       ; write address of library table
               dw       libraries
               call7    store_rf       ; and library table end
               dw       librariesend

               mov      rd,fildes1+4   ; setup dta for fildes1
               ldi      dta1.1
               str      rd
               inc      rd
               ldi      dta1.0
               str      rd

; ++++++++++++++++++++++++++++++++
; +++++ Setup virtual memory +++++
; ++++++++++++++++++++++++++++++++
               mov      rd,vramfildes+4 ; setup dta for vram fildes
               ldi      vram.1
               str      rd
               inc      rd
               ldi      vram.0
               str      rd
               mov      rf,vramfile    ; point to filename
               mov      rd,vramfildes  ; point to fildes
               ldi      3              ; create + truncate flags
               plo      r7
               ldi      0
               phi      r7
               call     o_open         ; call Elf/OS to open file
               lbdf     vramopenerr    ; jump if error
               mov      rf,buffer      ; need to zero buffer
               ldi      0              ; byte counter
               plo      rc
zero:          ldi      0              ; write zero to buffer
               str      rf
               inc      rf
               dec      rc             ; decrement count
               glo      rc             ; see if done
               lbnz     zero           ; loop until done
               ldi      0              ; need to write out 64k
               plo      rc
vramlp:        glo      rc             ; save counter
               stxd
               mov      rc,256         ; need to write 256 bytes
               mov      rf,buffer      ; from buffer
               call     o_write        ; write it
               lbdf     vramwrterr     ; jump if error
               irx                     ; recover count
               ldx
               plo      rc
               dec      rc             ; decrement count
               glo      rc             ; see if done
               lbnz     vramlp         ; loop until full file written

; ++++++++++++++++++++++++++++++++++++
; +++++ Setup virtual memory map +++++
; ++++++++++++++++++++++++++++++++++++
               mov      rd,mapfildes+4 ; setup dta for map fildes
               ldi      map.1
               str      rd
               inc      rd
               ldi      map.0
               str      rd
               mov      rf,mapfile     ; point to filename
               mov      rd,mapfildes   ; point to fildes
               ldi      3              ; create + truncate flags
               plo      r7
               ldi      0
               phi      r7
               call     o_open         ; call Elf/OS to open file
               lbdf     mapopenerr     ; jump if error
               ldi      32             ; need to write out 8k
               plo      rc
maplp:         glo      rc             ; save counter
               stxd
               mov      rc,256         ; need to write 256 bytes
               mov      rf,buffer      ; from buffer
               call     o_write        ; write it
               lbdf     mapwrterr      ; jump if error
               irx                     ; recover count
               ldx
               plo      rc
               dec      rc             ; decrement count
               glo      rc             ; see if done
               lbnz     maplp          ; loop until full file written




               mov      r7,microint    ; point r7 back to micro interpreter
               rtn

vramfile:      db       'vram.tmp',0
mapfile:       db       'map.tmp',0

               rtn

               public   vramfile
               public   mapfile

               endp
