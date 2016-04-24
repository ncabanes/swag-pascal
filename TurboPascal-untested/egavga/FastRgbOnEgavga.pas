(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0011.PAS
  Description: FAST RGB on EGA/VGA
  Author: GRADY WERNER
  Date: 05-28-93  13:39
*)

{
GRADY WERNER
Put these in your code For GREAT, FAST RGB Palette Changing...
}
Procedure ASetRGBPalette(Color, Red, Green, Blue : Byte);
begin
  Port[$3C8]:=Color;
  Port[$3C9]:=Red;
  Port[$3C9]:=Green;
  Port[$3C9]:=Blue;
end;

{
This Procedure Changes palette colors about 400% faster than the
built-in routines.  Also, a problem With flicker may have been encountered
with Turbo's Putimage Functions.  Call this Procedure RIGHT BEFORE the
putimage is called... Viola... NO Flicker!
}
Procedure WaitScreen;
begin
  Repeat Until (Port[$3DA] and $08) = 0;
  Repeat Until (Port[$3DA] and $08) <> 0;
end;

