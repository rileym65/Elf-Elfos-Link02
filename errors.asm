#include       macros.inc
#include       ../kernel.inc

               proc     errors

vramopenerr:   call     o_inmsg        ; display error
               db       'Error: Could not open vram.tmp',10,13,0
               lbr      o_wrmboot      ; return to Elf/OS

vramwrterr:    call     o_inmsg        ; display error
               db       'Error: Could not write vram.tmp',10,13,0
               lbr      o_wrmboot

mapopenerr:    call     o_inmsg
               db       'Error: Could not open map.tmp',10,13,0
               lbr      o_wrmboot      ; return to Elf/OS

mapwrterr:     call     o_inmsg
               db       'Error: Could not write map.tmp',10,13,0
               lbr      o_wrmboot

outwrterr:     call     o_inmsg
               db       'Error: Could not write output file',10,13,0
               lbr      o_wrmboot

               public   mapopenerr
               public   mapwrterr
               public   outwrterr
               public   vramopenerr
               public   vramwrterr

               endp

