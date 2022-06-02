#include       macros.inc
#include       ../kernel.inc

; *************************
; ***** Display CR/LF *****
; *************************
               proc     crlf

               call     o_inmsg        ; display cr/lf
               db       10,13,0
               rtn                     ; then return to caller

               endp
