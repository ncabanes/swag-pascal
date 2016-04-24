(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0145.PAS
  Description: Text Mode Copper Effects
  Author: PEDER HERBORG
  Date: 11-26-94  04:58
*)

{
One the effects from the Copper demo from S!P. Very old I know and very
simple, but still pretty, and not all new programmers know how control
the Vgacard yet.
}

Program floodfill;

uses crt;

Procedure SetGraphMode (Num:Byte);
begin
  asm
    mov al,Num
    mov ah,0
    int 10h
    end;
end;

Procedure Hsinc;assembler;      {waits for horizontal retrace} asm
      mov  dx,03dah
@lab1:in   al,dx
      test al,01
      jnz  @lab1
@lab2:in   al,dx
      test al,01
      jz   @lab2
end;

procedure Vsinc; assembler;    {waits for vertical retrace} asm
        push    ax
        push    dx

        mov     dx, 03dah
@@11:
        in      al,dx
        test    al,08h
        jnz     @@11
@@22:
        in      al,dx
        test    al,08h
        jz      @@22

        pop     dx
        pop     ax
end;

PROCEDURE Setpalette(X,R,G,B : Byte);


BEGIN
 Port[$3C8]:=X;   Port[$3C9]:=R;
 Port[$3C9]:=G;   Port[$3C9]:=B;
END;  { Setpalette }

var
  y,x,a,b,c:word;
  ch:char;

begin
  setgraphmode($13);
  setpalette(255,0,0,0);
  for a:=1 to 127 do setpalette(a,0,0,a div 2);
  for a:=0 to 127 do setpalette(a+127,0,0,127-a div 2);
  { this draws the circles. Put in a picture here instead }
  for y:=1 to 420 do
  for x:=1 {round(-sqrt(200*200 - y*y))} to round(sqrt(420*420 - y*y)) do
          if (x<320) and (y<200) then mem[$a000:(y)*320+x]:=(X*X+Y*Y) div 64;
  a:=399;
  repeat
  vsinc;
  PORT[$3D4]:=$13;       { normal screen}
  PORT[$3D5]:=40;
  for b:=1 to a do HSINC;{ waits until a certain scanline position on screen}
  PORT[$3D4]:=$13;       { floodfill screen screen}
  PORT[$3D5]:=0;
  dec(a,1);  { change here for more speed }
  until (keypressed) or (a<=0);
  PORT[$3D4]:=$13;
  PORT[$3D5]:=40;
  setgraphmode($3);
end.

