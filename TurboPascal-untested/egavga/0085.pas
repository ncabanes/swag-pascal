{
 To try out the program, some complex constants you can
 use are -1, -0.1+0.8i, 0.3-0.5i, -1.139+0.238i.  ie, when
 asked for the real part, enter 0.3.  For the imaginary,
 enter -.5 }

program julia;
{$N+,E+}
uses crt;
Type Real = double;
var  cx, cy, xo, yo, x1, y1 : real;
     mx, my, a, b, i, orb   : word;

label XXX;

procedure pset ( rx, ry: real; c:byte );
var a, x, y :word;
begin
  x := round(rx);
  y := round(ry);
  a := 320* pred(y) + x;
  mem[$A000:A] := c
end;
begin
  write('Real part: ');
  readln(CX);
  write('Imaginary part: ');
  readln(CY);
  asm
    mov ax, $13
    int 10h
  end;
  MX := 319; {  ' the box we want to plot on the screen }
  MY := 199;
  FOR A := 1 TO MX  do    {'X screen coordinate}
    FOR B := 1 TO MY do   {'Y screen coordinate  }
    begin
      XO := -2 + A / (MX / 4); {'X complex plane coordinate}
      YO :=  2 - B / (MY / 4);  {'Y complex plane coordinate}
      Orb := 0;
      FOR I := 1 TO 255 do     {'iterations for 255 colors}
      begin
        X1 := XO * XO - YO * YO + CX;
        Y1 := 2 * XO * YO + CY;
        IF X1 * X1 + Y1 * Y1 > 4.0 THEN  {'orbit escapes, plot it}
        begin
          Orb := I;
          GOTO XXX;
        END;
        XO := X1;
        YO := Y1;
      end;
XXX:
      PSET (A, B, Orb);  { 'plot orbit}
    end;
  readln;
  textmode(lastmode);
end.
