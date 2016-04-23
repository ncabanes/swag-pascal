{
Note: Original Code by Jort Bloem
      Edited to allow all VESA Modes by Kerry Sokalsky

> Okay thanks Jort, can you please give me an example of how to use what you
> gave me in the last message? For instance, let's say I wanted to put a
> pixel at 5,5 in mode 101h.
}

Uses
  Dos;  { For Registers Variable Type }

Const
  XSize = 800; { Enter the X-Resolution Here }

Var
  LastPage : Byte;
  Count,
  Count2   : Word;

{Ok..... here's some code. First, you need a procedure to set VGA mode:}
Procedure Videomode(VM:Word);
Var R:Registers;
Begin
 R.AX:=$4F02;
 R.BX:=VM;
 Intr($10,R);
End;

{You need a procedure to set the page. Pages are 64K (65535 bytes) each:}
Procedure Page(Pge:Byte);
Var R:Registers;
Begin
 LastPage:=Pge;
 R.AX:=$4F05;
 R.BX:=$0000;
 R.DX:=Pge;
 Intr($10,R);
End;

{Now the plot routine:}
Procedure Plot(X,Y,Clr:Word);
Var
 I:LongInt;
Begin
 I:=LongInt(Y)*XSize+LongInt(X);
 Page(I Div 65536);
 Mem[$A000:I Mod 65536]:=Clr;
End;

Begin
 VideoMode($103); { Set the Video Mode that corresponds to the X-Resolution
                    that was set as a constant }

 { Sample Viewing }
 For Count := 1 to 639 do
   For Count2 := 1 to 479 do
     Plot(Count,Count2,(Count + Count2) Mod 256);

 Readln;

 { Return to Text Mode }
 VideoMode($3);
End.

{
Note that you can optimise this slightly by checking if the page is already
correct before setting it. This is a general VESA routine, and should work
on all VESA cards (with VESA driver, if appropriate).
}