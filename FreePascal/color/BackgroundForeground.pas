(*
  Category: SWAG Title: TEXT/GRAPHICS COLORS
  Original name: 0017.PAS
  Description: Background/Foreground
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:34
*)

{
YZ> Does anyone know how to "extract" the Foreground and
YZ> background colours from
YZ> TextAttr?

or, For simplicity, use:

  FC := TextAttr MOD 16;
  BC := TextAttr div 16;

}
program colors;

uses crt;

var
    fc, bc: byte;

begin
    textAttr := 30;
    WriteLn('Hi!');
    
    FC := TextAttr MOD 16;
    BC := TextAttr div 16;
    WriteLn('FC=',fc,' BC=',bc);
    textcolor(fc);
    textbackground(bc);
    WriteLn('Hi 2!');
end.
