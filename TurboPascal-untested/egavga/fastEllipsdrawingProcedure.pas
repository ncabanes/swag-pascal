(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0286.PAS
  Description: fast ellips-drawing procedure
  Author: WOUTER 'TEUS' VAN REEVEN
  Date: 08-30-97  10:08
*)


{Dear Gayle and Jeff,


since a longtime I have been looking for a Pascal-routine that draws
an ellips with axes in a random direction on the screen. Up to now I
only found routines that draw ellipses with horizontal and vertical
axes.
But last friday I searched the SWAG-archive and found some files that
helped me develop the routine myself.

I found a fast ellips-drawing procedure by Bernie Pallek and
arotation-procedure by Mike Brennan. I have combined these two and I
found them to draw the ellips I wanted!


So attached to this mail is a file which contains the sought-after
procedures to draw an ellips with random axes. I hope you'll put it 
in the archive.


Many thanks to you for keeping such an archive. Without your help I'd
still be searching now!


Regards,


Wouter van Reeven




 Greetings                               *    *               *
 from Wouter van Reeven             *               *
 alias "Teus"                                                 *
                                                       *
 WReeven@ISD-Server.leidenuniv.nl      "Alone in the clouds all blue...."

 Only users lose drugs.        Clear skies!!!

{original 'Procedure Rotate' by Mike Brennan}
Procedure Rotate(cent1,cent2,angle:Integer;coord1,coord2:Real;clr:word);
Var coord1t, coord2t : Real;
    c1, c2 : integer;
begin
  coord1t := coord1 - cent1;
  coord2t := coord2 - cent2;
  coord1 := coord1t * cos(angle * pi / 180) - coord2t * sin(angle * pi / 180);
  coord2 := coord1t * sin(angle * pi / 180) + coord2t * cos(angle * pi / 180);
  coord1 := coord1 + cent1;
  coord2 := coord2 + cent2;
  c1 := round(coord1);
  c2 := round(coord2);
  putpixel(c1,c2,clr);
end;


{original 'Procedure Ellipse2' by Bernie Pallek. Original code by Sean Palmer}
{but, and I quote, Bernie 'mangled it'}
PROCEDURE Ellipse2(exc, eyc, ea, eb, i, clr : Integer);
VAR
  elx, ely : Integer;
  aa, aa2, bb, bb2, d, dx, dy : LongInt;
  x,y : real;
BEGIN
  elx := 0; ely := eb; aa := LongInt(ea) * ea; aa2 := 2 * aa;
  bb := LongInt(eb) * eb; bb2 := 2 * bb;
  d := bb - aa * eb + aa DIV 4; dx := 0; dy := aa2 * eb;
  x := exc; y := eyc - ely;
  rotate(exc,eyc,i,x,y,clr);
  x := exc; y := eyc + ely;
  rotate(exc,eyc,i,x,y,clr);
  x := exc - ea; y := eyc;
  rotate(exc,eyc,i,x,y,clr);
  x := exc + ea; y := eyc;
  rotate(exc,eyc,i,x,y,clr);
  WHILE (dx < dy) DO BEGIN
    IF (d > 0) THEN BEGIN Dec(ely); Dec(dy, aa2); Dec(d, dy); END;
    Inc(elx); Inc(dx, bb2); Inc(d, bb + dx);
    x := exc + elx; y := eyc + ely;
    rotate(exc,eyc,i,x,y,clr);
    x := exc - elx; y := eyc + ely;
    rotate(exc,eyc,i,x,y,clr);
    x := exc + elx; y := eyc - ely;
    rotate(exc,eyc,i,x,y,clr);
    x := exc - elx; y := eyc - ely;
    rotate(exc,eyc,i,x,y,clr);
  END;
  Inc(d, (3 * (aa - bb) DIV 2 - (dx + dy)) DIV 2);
  WHILE (ely > 0) DO BEGIN
    IF (d < 0) THEN BEGIN Inc(elx); Inc(dx, bb2); Inc(d, bb + dx); END;
    Dec(ely); Dec(dy, aa2); Inc(d, aa - dy);
    x := exc + elx; y := eyc + ely;
    rotate(exc,eyc,i,x,y,clr);
    x := exc - elx; y := eyc + ely;
    rotate(exc,eyc,i,x,y,clr);
    x := exc + elx; y := eyc - ely;
    rotate(exc,eyc,i,x,y,clr);
    x := exc - elx; y := eyc - ely;
    rotate(exc,eyc,i,x,y,clr);
  END;
END;


