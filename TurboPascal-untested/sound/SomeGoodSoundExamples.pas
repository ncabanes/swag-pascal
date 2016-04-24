(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0108.PAS
  Description: Some good sound examples
  Author: BOSTJAN GABROVSEK
  Date: 08-30-97  10:09
*)

{If you have any questions please send me mail at OleRom@hotmail.com}
Program Bomb;
Uses crt;
Var w : word;
     c : char;
Procedure space;
Begin
 w := 10;
 Repeat
   Inc(w,5);
   Sound(w*w);
   Delay(10);
   Sound(w*10);
   Delay(5);
 Until keypressed;
 NoSound;
End;
Procedure deep;
Var e : longint;
Begin
 e := 10;
 Repeat
  iNC(e,1000);
  Sound(Round(  (1/e*100)*100000));
  Delay(1);
 Until keypressed;
 NoSound;
End;
Procedure gun;
Begin
 w := 10;
 Repeat
  iNC(w,1000);
  Sound(Round(  (1/w*100)*100000));
  Delay(1);
 Until keypressed;
 NoSound;
End;
procedure Upping; ForWard;
Procedure shoot;
Begin
 w := 10;
 Repeat
  iNC(w,10);
  Sound(Round(  (1/w*100)*100000));
  Delay(1);
 Until w = 10000;
 upping;
 NoSound;
End;
Procedure upping;
Begin
 w := 10;
 Repeat
  iNC(w,1000);
  Sound(Round(  (1/w*100)*10000));
  Delay(1);
  Until keypressed;
{ Until (w < 600) and (w > 500);}
 NoSound;
End;
Procedure  Bombi;

Begin
 w := 10;
 Repeat
  iNC(w,100);
  Sound(Round(  (1/w*100)*100000));
  Delay(1);
 Until keypressed;
 NoSound;
End;
Begin
clrscr;
WriteLn;
Writeln('1 = MachineGun');
Writeln('2 = Laser');
Writeln('3 = HandBomb');
Writeln('4 = BigBomb');
Writeln('ESCAPE = EXIT');
Space;
Repeat
 c := readkey;
 If c = '1' then gun;
If c = '4' then
 shoot;
If c = '2' then Bombi;
If c = '3' then deep;
Until c=#27;
NoSOund;
End.
