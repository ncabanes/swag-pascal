(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0048.PAS
  Description: Turn SCREEN On/Off
  Author: SWAG SUPPORT TEAM
  Date: 11-26-93  17:40
*)

{
I use alot of line draws and some text on the screen....the lines come out
first and then the text a second or two later....is there a way so that the
whole output comes at once.  I tried Setvisualpage and setactivepage but the
the whole output screen is off.

        To Turn On/Off the Screen you may use these procedure
}
Procedure OnScreen;
Begin
     Port[$3c4]:=1;
     Port[$3c5]:=Screen_AttriBute_Tempolary;
end;

Procedure OffScreen;
Begin
     Port[$3c4]:=1;
     Screen_Attribute_Tempolary:=Port[$3c5];
     Port[$3c5]:=Screen_AttriBute_Tempolary or $20;
end;

