{
Someone has suggested that you use the BIOS routines, but I don't
think his code was complete.  In case you want to go the BIOS
route, I hacked out a routine that does that:
}

function Screen(row, column : byte): char; assembler;
{ returns the char at Row, Column }
asm
  MOV  AH, 0FH
  INT  10H       { Get active display page in BH, where it stays for
                   remainder of this routine }

  MOV  AH, 03H
  INT  10H       { Get current cursor settings for active display page }

  PUSH DX        { Save cursor coordinants on stack }

  MOV  DH, row
  MOV  DL, column
  DEC  DH        { Make allowance for the fact that BIOS treats origin }
  DEC  DL        { as 0,0, whereas we want it treated as 1,1           }
  MOV  AH, 02H
  INT  10H       { Move cursor to row-1, column-1 }

  MOV  AH, 08H
  INT  10H       { Get character at cursor in AL, where it stays until
                   returned by function }

  POP  DX        { Restore old cursor coordinates to DX }
  MOV  AH, 02H
  INT  10H       { Move cursor back where it was }
end;
---
 * Blue Lake System OR 503-656-9790 v.32bis 5 Node 12 Gig 
 * PostLink(tm) v1.20  BLUELAKE (#433) : RelayNet(tm)
                                                                                                           