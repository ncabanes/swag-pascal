{
> able to detect from another program (not the same program being run
> more than once) - is there a way?

You should be able to use the same code within another program.  The other
program should be able to call the user programmed interrupt, and get
$FFFF if the TSR is installed.

> from inside a TSR, which I guess is somewhat complicated because of
> the INDOS flag or what it's called, and I have no idea on how to do it.

You have to trap interrupt $28 as well.  It is called regularly during
the DOS console I/O polling loops to let TSRs know that it is safe to use
file operations.

As for the InDOS flag ... here you go ...
}

VAR

  InDOSSeg,           { Segment of the InDOS flag } 
  InDOSOfs  : WORD;   {  Offset of the InDOS flag } 
  InDOSFlg  : ^BYTE;  {  Status of the InDOS flag } 
 
{ Returns TRUE if DOS is active } 
FUNCTION InDOS : BOOLEAN; 
VAR 
  InDOSSeg, 
  InDOSOfs  : WORD; 
  InDOSFlg  : ^BYTE; 
 
Begin 
  asm 
    mov ah, $34 
    int $21 
    mov InDOSSeg, ES 
    mov InDOSOfs, BX 
  End; 


  InDOSFlg := Ptr( InDOSSeg, InDOSOfs ); 
 
  InDOS := (InDOSFlg^ <> 0); 
End; 

{
Call this procedure ONCE and only ONCE at the start of your TSR.  Then
use the last line (InDOSFlg^ <> 0) to check to see if DOS is performing
a function call.
}
