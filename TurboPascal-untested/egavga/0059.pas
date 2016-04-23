(*
From: MIGUEL MARTINEZ              Refer#: NONE
Subj: 80x30 Text-Mode Procedure      Conf: (1617) L-Pascal
---------------------------------------------------------------------------
Hello to everyone!. A friend of mine who enjoys Assembler, has developed a
routine, to provide "another" video mode to all those who develop text-based
programs.

It's a routine to set a 80x30 text mode, using the 16x8 font of the VGA.
I think is a better mode to work, than the standard 80x25 mode: More
information on screen, without loosing the pretty 16x8 chars.

I have translated this routine to Pascal, and here is the result. It will
work on any standard VGA card.
*)

{Procedure to set 80 columns per 30 rows video mode}
{Orignial Author: Ignacio García Pérez}
Procedure Set80x30Mode;
Var CrtcReg:Array[1..8] of Word;
    Offset:Word;
    i,Data:Byte;
Begin
  CrtcReg[1]:=$0c11;           {Vertical Display End (unprotect regs. 0-7)}
  CrtcReg[2]:=$0d06;           {Vertical Total}
  CrtcReg[3]:=$3e07;           {Overflow}
  CrtcReg[4]:=$ea10;           {Vertical Retrace Start}
  CrtcReg[5]:=$8c11;           {Vertical Retrace End (& protect regs. 0-7)}
  CrtcReg[6]:=$df12;           {Vertical Display Enable End}
  CrtcReg[7]:=$e715;           {Start Vertical Blanking}
  CrtcReg[8]:=$0616;           {End Vertical Blanking}

  MemW[$0040:$004c]:=8192;     {Change page size in bytes}
  Mem[$0040:$0084]:=29;        {Change page length}
  Offset:=MemW[$0040:$0063];   {Base of CRTRC}
  Asm
    cli                        {Clear Interrupts}
  End;

  For i:=1 to 8 do
    PortW[Offset]:=CrtcReg[i]; {Load Registers}

  Data:=Port[$03cc];
  Data:=Data And $33;
  Data:=Data Or $C4;
  Port[$03c2]:=Data;
  Asm
   sti                         {Set Interrupts}
   mov ah,12h                  {Select alternate printing routine}
   mov bl,20h
   int 10h
  End;
End; {Of Procedure}

BEGIN
Set80X30Mode;
END.

