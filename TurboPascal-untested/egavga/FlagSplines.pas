(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0227.PAS
  Description: Flag Splines
  Author: BAS VAN GAALEN
  Date: 05-26-95  23:28
*)

program sinmap;
{ Source by Bas van Gaalen, Holland, PD }
uses crt;
const
  gseg : word = $a000;
  spd = 2; size = 3; curve = 125;
  xmax = 150 div size;
  ymax = 100 div size;
  sofs = 50; samp = 10; slen = 255;
var stab : array[0..slen] of word;

procedure csin; var i : byte; begin
  for I := 0 to slen do stab[i] := round(sin(i*4*pi/slen)*samp)+sofs; end;

procedure displaymap;
type scrarray = array[0..xmax,0..ymax] of byte;
var
  postab : array[0..xmax,0..ymax] of word;
  bitmap : scrarray;
  x,y,xp,yp,sidx : word;
begin
  fillchar(bitmap,sizeof(bitmap),0);
  sidx := 0;
  for x := 0 to xmax do
    for y := 0 to (ymax div 3) do bitmap[x,y] := lightred;
  for x := 0 to xmax do
    for y := (ymax div 3) to 2*(ymax div 3) do bitmap[x,y] := white;
  for x := 0 to xmax do
    for y := 2*(ymax div 3) to ymax do bitmap[x,y] := lightblue;
  repeat
    while (port[$3da] and 8) <> 0 do;
    while (port[$3da] and 8) = 0 do;
    for x := 0 to xmax do
      for y := ymax downto 0 do begin
        mem[gseg:postab[x,y]] := 0;
        xp := size*x+stab[(sidx+curve*x+curve*y) mod slen];
        yp := size*y+stab[(sidx+4*x+curve*y+y) mod slen];
        postab[x,y] := xp+yp*320;
        mem[gseg:postab[x,y]] := bitmap[x,y];
      end;
    sidx := (sidx+spd) mod slen;
  until keypressed;
end;

begin
  csin;
  asm mov ax,13h; int 10h; end;
  displaymap;
  textmode(lastmode);
end.

