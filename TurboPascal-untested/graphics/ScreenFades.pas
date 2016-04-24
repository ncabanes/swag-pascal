(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0018.PAS
  Description: Screen Fades
  Author: CHRIS BEISEL
  Date: 08-27-93  21:03
*)

{
CHRIS BEISEL

I've gotten many compliments on these two fade routines (a few good
programmers thought they were asm!)... plus, I made them so you can fade
part on the palette also... It's very smooth on my 486, as well as 386's
and 286's at friends houses...

        set up in your type declarations
                rgbtype=record
                    red,green,blue:byte;
                end;
                rgbarray[0..255] of rgbtype;

        and in your var declarations have something like
                rgbpal:rgbarray;

        and set your colors in that...
}
procedure fadein(fadepal : rgbarray; col1, col2 : byte);
var
  lcv,
  lcv2 : integer;
  tpal : rgbarray;
begin
  for lcv := col1 to col2 do
  begin
    TPal[lcv].red   := 0;
    TPal[lcv].green := 0;
    TPal[lcv].blue  := 0;
  end;
  for lcv := 0 to 63 do
  begin
    for lcv2:=col1 to col2 do
    begin
      if fadepal[lcv2].red > TPal[lcv2].red then
        TPal[lcv2].red := TPal[lcv2].red + 1;
      if fadepal[lcv2].green > TPal[lcv2].green then
        TPal[lcv2].green := TPal[lcv2].green + 1;
      if fadepal[lcv2].blue > TPal[lcv2].blue then
        TPal[lcv2].blue := TPal[lcv2].blue+1;

      setcolor(lcv2, TPal[lcv2].red, TPal[lcv2].green, TPal[lcv2].blue);
    end;
    refresh;
  end;
end;

{*******************************************************************}

procedure fadeout(fadepal : rgbarray; col1, col2 : byte);
var
  lcv,
  lcv2 : integer;
  TPal : rgbarray;
begin
  for lcv := col1 to col2 do
  begin
    TPal[lcv].red   := 0;
    TPal[lcv].green := 0;
    TPal[lcv].blue  := 0;
  end;
  for lcv := 0 to 63 do
  begin
    for lcv2 := col1 to col2 do
    begin
      if fadepal[lcv2].red > TPal[lcv2].red then
        fadepal[lcv2].red := fadepal[lcv2].red - 1;
      if fadepal[lcv2].green > TPal[lcv2].green then
        fadepal[lcv2].green := fadepal[lcv2].green - 1;
      if fadepal[lcv2].blue > TPal[lcv2].blue then
        fadepal[lcv2].blue := fadepal[lcv2].blue - 1;

      setcolor(lcv2, fadepal[lcv2].red, fadepal[lcv2].green, fadepal[lcv2].blue);
    end;
    refresh;
  end;
end;

{*******************************************************************}


