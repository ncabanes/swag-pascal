(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0153.PAS
  Description: Planar 16 Color Mode Plot
  Author: JORT BLOEM
  Date: 11-26-94  04:58
*)

{
> I have not seen a correct SetPixel routine for a planar 16 color mode.  It
> does not have to be fast or optimized, just working correctly so I can see
> how it's done.

Well, I found something that you can fiddle around with, it's not exactly
working (well, kind of), but it shows the principle... all the Ports are
right, what's going in & out is right, just the FillChar needs to be fixed
up to plot only a single pixel or group thereof.
}
Program Try_EGA;
Uses CRT;

Var Scr:Byte Absolute $A000:0;
    Loop:Word;

Procedure Mode_10;
Inline($B8/$0d/$00/$CD/$10);{Intr $10, AX=$000D}

Procedure Write;
Begin
 {Write mode}
 Port[$03CE]:=5;
 Port[$03CF]:=Port[$03CF] And $FC;
End;

Procedure Undo_Latches;
Begin
 If Scr=1 Then
  Begin
  End;
End;

Procedure Bmp(Bmp:Byte);
Begin
 {Plane}
 Port[$03CE]:=8;
 Port[$03CF]:=Bmp;
End;

Procedure Color(C:Word);
Begin
 PortW[$03CE]:=C*256;
 PortW[$03CE]:=$0F01;
End;

Procedure Show(Bm,Clr:Word);
Begin
 Bmp(Bm);
 Color(Clr);
 Undo_Latches;
 FillChar(Scr,8000,$FF);
 Delay(1000);
End;

Begin
 Mode_10;
 Write;

 Delay(1000);

 Show($11,1);
 Show($22,2);
 Show($44,3);
 Show($88,4);
 Show($10,5);
 Show($20,6);
 Show($40,7);
 Show($80,8);

 Delay(1000);
End.
{

Bmp says which pixels of any group of 8 is affected... the screen looks like
this:

1234567812345678123456781234567812345678.....
1234567812345678123456781234567812345678.....
1234567812345678123456781234567812345678.....
.
.
.

Thus if you want the first & 3rd pixel green, do
}
 Color(Green);
 Bmp(5);       {Bits 1 & 3 set}
 Undo_Latches;
 Mem[$A000:0]:=$FF; {I think}
{
I dont know what Undo_Latches does, but it seems to work...

BTW, I saw mention of a VESA unit you were writing, as a reward for this
information.... do I qualify? I'm very interested....
}

