(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0174.PAS
  Description: Vector Ball Ellipse Splash
  Author: CAMERON CLARK
  Date: 11-26-94  04:59
*)

{
{Places a large vector ball ellipse on the screen and makes it bounce
 to pieces= nice visual effect}
uses crt;
const Balls = 1400;
      startcolor=50;
type movement= record
     x,   y : integer;  { position }
    dx,  dy : integer;  { velocity }
   ddx, ddy : integer;  { acceleration }
   color    : integer;
   MaxYValue: integer;
        END;
VAR ch : char;
    I,
    Pull  : integer;
    Dummy : string;
    Ball  : array[1..BAlls] of movement;
procedure PutDot(x,y,color:integer);
  begin
    Mem[$a000{VGA_Segment}:(y*320)+x] := color;
  end;
Procedure VideoMode ( Mode : Byte );
    Begin { VideoMode }
      Asm
        Mov  AH,00
        Mov  AL,Mode
        Int  10h
      End;
    End;  { VideoMode }
Procedure SetColors ( Color, Red, Green, Blue : Byte );
    Begin { SetColor }
      Port[$3C8] := Color;
      Port[$3C9] := Red;
      Port[$3C9] := Green;
      Port[$3C9] := Blue;
    End;  { SetColor }
BEGIN {MAIN}
videoMODE($13);
for I:=1 to 250 do setcolors(I,i mod 50,
                             i mod 50-20,
                             I div ((i div 63)+1));
fillchar(mem[$A000:(191*320)],320*8,Ord(StartColor));{line at bottom}
FOR I:=1 to BAlls do BEGIN {INIT the balls into the array}
WITH ball[i] do BEGIN
  ddx  := 0;
  ddy  := 1;             {constant pull downward}
  dx   := Random(5)-2;   { start it moving left or right }
  if dx=0 then dx:=1;    { not still}
  dy   := 0;             { the object is initially at rest }
  x    := trunc(cos(i)*140)+140+((i div ((i div 4)+1))*6);
  y    := trunc(Sin(I+((i div ((I div 4)+1))))*70)+60+
          ((i div ((I div 4)+1)*12)); {   you specified }
  color:=Random( I div ((I div 254)+1)) + 1;  {Each Balls color}
  MaxYValue:=Y;
END; {with}
END; {for do loop}
Pull:=0; {init the gravity degrading effect}
WHILE not(keypressed) do begin
 FOR I:=1 to Balls do BEGIN
  With ball[I] do BEGIN
  putdot(x, y, 0);    { blank out the pixel drawn on the last iteration }
  dx := dx + ddx;     { updating velocity }
  dy := dy + ddy;
  x  :=  x +  dx;     { updating position }
  y  :=  y +  dy;
  IF x< 1 then begin      {hits left of screen}
     X  := 1;
     dx := dx*-1;
  End;
  IF x > 319 then begin   {hits right of screen}
     x  := 319;
     dx := -dx;
  END;
  IF y > 190 then begin   { BOUNCE! }
     y  := 190-(y-190)+1;
     dy := -dy+pull;
  End;
  putdot(x, y, color);  { draw the pixel at the new position }
  END; {WITH}
 END; {for do loop}
END; {KEYPRESS}
VideoMODE($3);
END. {PROGRAM}

