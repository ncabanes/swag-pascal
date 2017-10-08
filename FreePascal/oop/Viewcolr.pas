(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0021.PAS
  Description: VIEWCOLR.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

(*
> Does somebody know how to get correct colors in a view.
> That is: Exactly the colors I want to specify without mapping
> on the colors of the views owner?

Now you're getting even more complicated than the actual method of doing it.
(as if that wasn't complicated enough!)

The BP7 Turbo Vision Guide (and I'll assume the TP7 TVGuide as well) do a much
better job at explaning the palette's that the TP6 version. The colors are not
as much maps, as they are indexes. Only the TProgram Object actual contains any
color codes. TApplication, by design, inherits that palette as is. Any inserted
views palette will contain a String of indexes into that palette.

There are a couple of ways to customize your colors. Either adjust where your
current views index points to, or adjust the actual applications palette.

> The manual says that such is done to get "decent colors". But the
> problem is that defining what should be "decent" is to the Programmer,
> not to the designer of a compiler :-)

> How to get just Absolute colors in a view, thats the question.

The easiest method I've found For adjusting colors, is directly adjusting the
actual TApllications GetPalette Method.


Function TMyApp.GetPalette:PPalette;
Const
  P: Array[apColor..apMonochrome] of String[Length(CColor)] =
    (CColor, CBlackWhite, CMonochrome);
begin
  p[apcolor,1] := #$1A;   {background}
  p[apcolor,2] := #$1F;   {normal Text}
  p[apcolor,33] := #$74;  {tdialog frame active}
  p[apcolor,51] := #$1B;  {inputline selected}
  p[apcolor,56] := #$4F;  {history Window scrollbar control}
  getpalette := @p[apppalette];
end;


This lets you change and adjust your entire pallete, and have those changes
reflected throughout your entire application... Just consult your TVGuide to
find the offset into the String of the item you want to change.

Heres a nifty Program to display all the colors available, and what they look
like (not only tested.. but used quite a bit!) :
*)

Program Colourtest;

Uses
  Crt;
Type
  str2 = String[2];
Var
 i, y, x,
 TA       : Byte;

Function Hexit(w : Byte) : str2;
Const
  Letr : String[16] = '0123456789ABCDEF';
begin
  Hexit := Letr[w shr 4 + 1] + Letr[w and $0F + 1];
end;

begin
  TA := TextAttr ;
  ClrScr;
  For y := 0 to 7 do
  begin
    GotoXY(1, y + 5);
    For i := 0 to 15 do
    begin
      TextAttr := y * 16 + i;
      Write('[', Hexit(TextAttr), ']');
    end;
  end;
  Writeln;
  Writeln;
  GotoXY(1, 15);
  Textattr := TA;
  Write(' For ');
  Textattr := TA or $80;
  Write(' Flashing ');
  Textattr := TA;
  Writeln('Attribute : Color = Color or $80');
  Writeln;
  Write(' Press any key to quit : ');
  ReadKey;
  ClrScr;
end.
