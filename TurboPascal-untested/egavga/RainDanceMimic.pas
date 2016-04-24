(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0150.PAS
  Description: Rain Dance Mimic
  Author: CAMERON CLARK
  Date: 11-26-94  04:58
*)

{
movement mimics dancing rain? [closest analogy I can think of]
}
uses crt;
const Balls = 1900;  {increment if too fast: decrement if too slow}
type movement= record
     x,   y : integer;  { position }
    dx,  dy : integer;  { velocity }
   ddx, ddy : integer;  { acceleration }
   color    : integer;
   MaxYValue: integer;
        END;
VAR ch : char;
    I  : integer;
 Ball: array[1..BAlls] of movement;
Procedure VideoMode ( Mode : Byte );
    Begin { VideoMode }
      Asm
        Mov  AH,00
        Mov  AL,Mode
        Int  10h
      End;
    End;  { VideoMode }
procedure PutDot(x,y,color:integer);
  begin
    Mem[$A000{VGA_Segment}:(y*320)+x] := color;
  end;
 
BEGIN
videoMODE($13);
randomize;
{init all balls}
for i:=1 to BAlls do BEGIN
With ball[i] do BEGIN
ddx := 0;             { no horizontal acceleration }
ddy := 1;             { constant vertical acceleration }
 dx := Random(2)-1;   { push it left of right to start}
 if dx=0 then dx:=1;  { all balls will have a horizontal movement}
 dy:=0;               { the object is initially at rest }
  x := I div ((i div 320)+1); { initial coordinates, as }
  y := i mod 130+random(3); {   you specified }
  color:=random(I mod 255);  {Each Balls color}
  MaxYValue:=Y+1;
END; {with}
END; {for do loop}
WHILE not(keypressed) do begin
 FOR i:=1 to Balls do BEGIN
  With ball[i] do BEGIN
  putdot(x, y, 0);    { blank out the pixel drawn on the last iteration }
  dx := dx + ddx;     { updating velocity }
  dy := dy + ddy;
  x  :=  x +  dx;     { updating position }
  y  :=  y +  dy;
  IF x< 1 then begin      {hits left of screen}
     X:=1;
     dx:=dx*-1;
  End;
  IF x > 319 then begin   {hits right of screen}
     x :=319;
     dx:=-dx;
  END;
  IF y > 190 then begin   { BOUNCE! }
    y := 190;
    dy := -dy;
  End;
  putdot(x, y, color);  { draw the pixel at the new position }
  END; {WITH}
 END; {for do loop}
End; {KEYPRESS}
videoMODe($3);
end. {PROGRAM}


