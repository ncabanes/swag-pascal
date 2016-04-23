{gravity type program modified by ■Mr. Krinkle■}
uses {vgaSCRN,}crt;
const Balls = 900;  {if program too fast increase: if too slow decrease}

type movement= record
     x,   y : integer;  { position }
    dx,  dy : integer;  { velocity }
   ddx, ddy : integer;  { acceleration }
   color    : integer;
   MaxYValue: integer;
END;

VAR ch : char;           {for readkey}
    I  : integer;
  Ball : array[1..BAlls] of movement;

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

BEGIN {MAIN}
videoMODE($13); {320x200x256c}
{init all balls}
FOR I:=1 to BAlls do BEGIN
With ball[i] do BEGIN
ddx := 0;             { constant horizontal acceleration }  {gravity < or >}
ddy := 0;             { constant vertical acceleration } {gravity ^ or v }

{ in this case there is NO gravity pull from ANY direction: ... weightless}

 dx := Random(2)-1;             { initial velocity < or >}
 dy := -1;                      { initial velocity ^ or v}

  x := i mod 305+random(15)+1; { initial coordinates, as }
  y := I mod 190+random(10)+1; {   you specified }

{320 * 200 positioning : take I and remainder when divided by 'balls'
                         to produce a sequential increment that
                         does not over flow 320 or 200; plus a random
                         to give the fuzzy line effect}

  color:=Random( I div ((I div 254)+1)) + 1;  {Each Balls color}
                   { This formula will take a loop from 1 to [any number]
                     and make it so it will increment from 1 to 255
                     [valid color assignments]}
  MaxYValue:=Y+1;  {future use only}
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
     dx:=dx*-1;           {moves it to the right}
  End;
  IF x > 319 then begin   {hits right of screen}
     x :=319;
     dx:=-dx;             {moves it to the left}
  END;
  IF y > 190 then begin   { BOUNCE! }
    y := 190;
    dy := -dy;            {not used: all object float upward not down}
  End;
  putdot(x, y, color);  { draw the pixel at the new position }
  END; {WITH}
 END; {for do loop}
End; {KEYPRESS}
videoMODe($3);          {back to text mode}
end. {PROGRAM}
