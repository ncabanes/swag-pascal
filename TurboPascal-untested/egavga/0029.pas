{CD>     Can someone tell me how to get 320x200x256 screen mode in Turbo
CD>Pascal 5.5.

Yes.
}
Program DemoMode13;
Uses Dos,Crt;
Var
 LM : Word;
 CD : Word;

{
; Enable 320*200*256, return True if successful, otherwise False
;
; Reasons For False return : Already in mode 13, mode 13 unsupported.
}
Function Enable13:Boolean;
 Var
  Regs : Registers;
 begin
  LM:=LastMode;
  Regs.AH:=$0F;
  intr($10,Regs);
  if Regs.AL<>$13 then begin
   Regs.AH:=$03;
   intr($10,Regs);
   CD:=Regs.CX;
   Regs.AX:=$0013;
   intr($10,Regs);
   if (Regs.Flags and 1)=0 then begin
    Enable13:=True;
   end else begin
    Enable13:=False;
   end;
  end else begin
   Enable13:=False;
  end;
 end;

{
; Exit 310*200*256 mode, True if successful, False if not
;
; Reasons For False return : not in mode 13.
}
Function Release13:Boolean;
 Var
  Regs : Registers;
 begin
  Regs.AH:=$0F;
  intr($10,Regs);
  if Regs.AL=$13 then begin
   TextMode(LM);
   Regs.AH:=$01;
   Regs.CX:=CD;
   intr($10,Regs);
   Release13:=True;
  end else begin
   Release13:=False;
  end;
 end;

{
; Plot a pixel in 320*200*256 mode.
;
; This may appear quite obvious at first, but take a closer look if you think
; it is Really simple.  if you read your Turbo Pascal book, though, you are
; required to only ponder the usage of `Absolute' For a moment.
}
Procedure DrawPixel(X,Y:Word;Colour:Byte);
 Var
  Screen : Array [0..319,0..199] of Byte Absolute $A000:$0000;
 begin
  Screen[Y,X]:=Colour;
 end;

{
; Main Program.  Draws points in four corners in random colours, reads a like
; of Text (odd, but it displays it!) then returns to Text mode and quits.
}
begin
 Writeln;
 CheckBreak:=False;
 CheckSnow:=False;
 DirectVideo:=False;
 if Enable13 then begin
  Randomize;
  DrawPixel(0,0,Random(255));
  DrawPixel(319,0,Random(255));
  DrawPixel(0,199,Random(255));
  DrawPixel(319,199,Random(255));
  GotoXY(1,2);
  Writeln('Type something then press [Enter]');
  readln;
  if (not enable13) then begin
   ClrScr;
  end else begin
   Writeln;
   Writeln('Error Exiting mode 13.');
   Writeln('Enter MODE CO80 or MODE MONO to');
   Writeln('restore your screen to Text mode.');
  end;
 end else begin
  Writeln('Error invoking mode 13');
 end;
 Writeln;
end.
