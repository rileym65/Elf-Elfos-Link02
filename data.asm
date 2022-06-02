; Symbol table starts high in memory and builds down
; Reference tables starts low in memory and builds up

               proc     data

address:       dw       0              ; current load address
addressmode:   db       0              ; big or little endian
buffer:        ds       256            ; i/o buffer
buffer2:       ds       64             ; temp buffer
ctrlfildes:    ds       19             ; fildes for control file
ctrldta:       ds       512            ; dta for control file
dta1:          ds       512            ; general dta
fildes1:       ds       19             ; general fildes
lowest:        dw       0              ; lowest address used
highest:       dw       0              ; highest address used
inproc:        db       0              ; flag if inside PROC
libraries:     dw       0              ; address of library table
librariesend:  dw       0              ; address of library table end
libtable:      ds       256            ; storage table for libraries
libscan:       db       0              ; flag for scanning libraries
loadmodule:    db       0              ; flag for loading a module
mapfildes:     ds       19             ; memory map fildes
map:           ds       512            ; space for memory map
objcount:      dw       0              ; object file counter
offset:        dw       0              ; PROC module offset
outmode:       db       0              ; output file mode
outname:       ds       80             ; storage for output name
references:    dw       0              ; address of reference table
referencesend: dw       0              ; address of reference table end
resolved:      dw       0              ; count of resolved references
showsymbols:   db       0              ; whether or not to show symbols
startaddress:  dw       0              ; program start address
symbols:       dw       0              ; address of symbol table
vramfildes:    ds       19             ; VRAM fildes
vram:          ds       512            ; space for virtual memory
freemem:       db       0              ; beginning of available memory

               public   address
               public   addressmode
               public   buffer
               public   buffer2
               public   ctrlfildes
               public   ctrldta
               public   dta1
               public   fildes1
               public   freemem
               public   highest
               public   inproc
               public   libraries
               public   librariesend
               public   libscan
               public   libtable
               public   loadmodule
               public   lowest
               public   map
               public   mapfildes
               public   objcount
               public   offset
               public   outmode
               public   outname
               public   references
               public   referencesend
               public   resolved
               public   showsymbols
               public   startaddress
               public   symbols
               public   vramfildes
               public   vram
               endp

