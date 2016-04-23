(*
> Is there someone who can tell me how I can CREATED my own .SYS files ?

Try "Advanced MSDOS Programming", by Ray Duncan (Microsoft Press) for details
about device driver writing.

A device driver is a binary image whose origin is at zero.  The first two
words in the header are always $FFFF.  Device attribute varies per device!
{ start of device driver header }
   ORG  0
dd -1          { Next device : longint = -1; }
dw $8800       { Device attribute word, "generic" driver for DOS 3 or later }
dw strategy    { Strategy routine offset (request header pointer entry) }
dw intrupt     { Interrupt routine offset (request entry point) }
db 'EXAMPLE '  { Eight character device name }
{ Global variables }
request_ptr LABEL dword
request_off  DW  ?
request_seg  DW  ?
{ end of device driver header }

{ "dos_func_table" is used by "intrupt" to call the routine that handles
  the requested function.  Example table with four command entries: }
max_cmd EQU 4
dos_func_table:  DW dosfunc0, nopcmd, nopcmd, badcmd
{ Typical table has 24 entries including nopcmd's and badcmd's.  dosfunc0
 initializes device driver interrupts and buffers, then gives ending address
 of the device driver (header + body) to DOS.
  MediaCheck       ; not used for character devices -- return done
  BuildBPB         ; not used for character devices -- return done
  IOCTLRead        ; disabled in table word
      Read           ; implemented for character device
      NdRead         ; implemented "   "         "
      InpStatus      ; implemented "   "         "
      InpFlush       ; implemented "   "         "
      Write          ; implemented "   "         "
      WriteVerify    ; implemented "   "         "
      OutStatus      ; implemented "   "         "
      OutFlush       ; not used in this example -- always success
  IOCTLWrite       ; disabled in table word
  DevOpen          ; disabled in table word
  DevClose         ; disabled in table word
  RemMedia         ; disabled in table word
  OutBusy          ; disabled in table word
  GenIOCTL         ; disabled in table word
  GetLogDev        ; not used for character devices -- return done
  SetLogDev        ; not used for character devices -- return done }

{ "Strategy" routine called by DOS with a request.  This implementation just
  saves the request. }
strategy proc far
   MOV  CS:request_off, BX
   MOV  CS:request_seq, ES
   RET
strategy endp
{ "Intrupt" routine handles request queued by "strategy".  Calls one of the
  subroutines in the function table depending upon the request number.  Each
  subroutine returns with exit status in AX.  Partial example: }
intrupt proc far
   STI
   PUSHA             { Preserve all registers except stack }
   PUSH DS
   PUSH ES
   { Read requested function information into registers }
   LDS  BX, CS:request_ptr
   XOR  AH, AH
   MOV  AL, DS:[BX+02h]       { AL = function code }
   CMP  AL, max_cmd  { Check range for expected table entry }
   JA   unknown_command
   XCHG BX, AX
   SHL  BX, 1        { Calculate index to function table of words }
   MOV  AX, CS
   MOV  DS, AX
   CALL word ptr dos_func_table[BX]
done:
   LDS  BX, CS:request_ptr       { Report status }
   OR   AX, 100h                 { Always set done bit before exit }
   MOV  [BX+03], AX
   POP  ES
   POP  DS
   POPA              { Restore all registers }
   RET               { Return to DOS }
unknown_command:
   CALL badcmd       { Your error routine for invalid codes }
   JMP  done
intrupt endp
{ Invalid function request by DOS }
badcmd proc near
   MOV  AX, 813h     { Return "Error: invalid command" }
   RET
badcmd endp
{ Unimplemented function request by DOS will return 0=SUCCESS }
nopcmd proc near
   XOR  AX, AX       { No error, not busy }
   RET
nopcmd endp
dosfunc0 proc near .. endp
*)