(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0179.PAS
  Description: VGA - Borland Palette Explained
  Author: RANDALL ELTON DING
  Date: 05-26-95  23:23
*)

(*
From: randyd@alpha2.csd.uwm.edu (Randall Elton Ding)

>the 'Help' doc says I should be able to change
>the RGB settings of any of the 16 colors using
>SetRGBPalette, but it only seems to work for colors 0 to 6.
>
>Can someone give me some real Help please?
>
>Extremely annoyed -- Jeoff

The docs for SetRGBPalette are very confusing.  The ColorNum variable
is not the first 16 palette entries.  Borland's 16 color Palette is
mapped into the VGA 256 color Palette.  The below constant ColorMap
defines the mapping.

const  ColorMap : array[0..15] of word =  {256 to 16 color palette mapping}
         (0, 1, 2, 3, 4, 5, 20, 7, 56, 57, 58, 59, 60, 61, 62, 63);

  For example: The 15th color in Borland's Palette is really the 63th color
               in the VGA Palette.

I reason this was done was to have the standard 16 colors without having to
modify the default VGA palette.  Here is a sample program that changes
the Palette for VGA mode.  It draws color bars for the 16 colors, then
changes the Palette to gray shades.  Press any key between changes and
to exit the program.  Enjoy.
*)
{
Randy.
randyd@alpha2.csd.uwm.edu
finger for 1024 bit pgp2.6 public key
key fingerprint 6D A1 28 15 42 BE 9B 6C  C0 1C 7E 88 A6 1E 3A B8
}

{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
program palettechange;

uses  crt, graph;

const  ColorMap : array[0..15] of word =        {256 to 16 palette mapping}
         (0, 1, 2, 3, 4, 5, 20, 7, 56, 57, 58, 59, 60, 61, 62, 63);

var  graphdriver, graphmode, mx, my, bx, i : integer;

begin
  graphdriver:= vga;
  graphmode:= vgamed;
  initgraph(graphdriver, graphmode, 'e:\bp\bgi'); {!!! change accordingly !!!}
  if graphresult = 0 then begin
    mx:= getmaxx;
    my:= getmaxy;
    bx:= (mx + 1) div 16;
    for I:= 0 to 15 do begin
      SetFillStyle(SolidFill, i);
      bar( I * bx, 0, (I * bx) + bx, my);
    end;
    repeat until keypressed;
    readkey;
    for I:= 0 to 15 do setrgbpalette(ColorMap[i], i * 4, i * 4, i * 4);
    repeat until keypressed;
    readkey;
    closegraph;
  end
end.


