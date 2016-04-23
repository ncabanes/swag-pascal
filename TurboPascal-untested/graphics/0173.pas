{
> I can't get the Graphics Programming thingy, so can you explain to
> theory for making circles with the above algorithms?  Is it possible to for
> the sines and cosines and use another method because anything with sines an
> cosines (without a lookup table) would be too slow.

I can give you the Bresenham algorithm adapted to 320x200x256 mode.  The
Bresenham method is very quick and only uses integer math so there are no
complex math functions to slow it down.  Yet it still draws accurate circles.
This code has been tested, but there were a few things I had to modify, so I
can't guarantee it will work.  Mail me back if for some reason it doesn't.
}

Procedure Circle(Cx, Cy, y : integer; color : byte);

{ Draws circle with center (Cx, Cy) and radius y }
{ Bresenham's circle algorithm implemented }
{ Edge-of-screen clipping implemented }

const              { various and sundry lookup tables for efficiency }
  Change : array[0..1, 0..7] of integer =
    ((1-SW, -1-SW, 1+SW, -1+SW, SW-1, SW+1, -SW-1, -SW+1),
     (1, -1, 1, -1, SW, SW, -SW, -SW));
  ChangeY : array[0..1, 0..7] of integer =
    ((-1, -1, 1, 1, 1, 1, -1, -1),
     (0, 0, 0, 0, 1, 1, -1, -1));
  ChangeX : array[0..1, 0..7] of integer =
    ((1, -1, 1, -1, -1, 1, -1, 1),
     (1, -1, 1, -1, 0, 0, 0, 0));

var
  i, D, x : integer;  {int i, D = 3 - (y << 1);}
  TempNeg : Boolean;  {int x, tempneg;}
  RealX, RealY : array[0..7] of integer;  {int realx[8];}
                                          {int realy[8];}
  
  TempAddr : word;
  Addr : array[0..7] of word;  {unsigned int tempaddr, addr[8];}
  ch : char;

begin
  D := 3 - (y shl 1);                  { initialize decision variable }
  for i := 0 to 3 do begin             { set up coordinates of symmetry }
    RealX[i] := Cx;                    {    ___    }
    RealY[i+4] := Cy end;              {   /3\   }
  RealX[6] := Cx+y;                    {  /7\|/6\  }
  RealX[4] := RealX[6];                {  |-----|  }
  RealX[7] := Cx-y;                    {  \5/|\4/  }
  RealX[5] := RealX[7];                {   \1/   }
  RealY[1] := Cy+y;                    {    ---    }
  RealY[0] := RealY[1];
  RealY[3] := Cy-y;
  RealY[2] := RealY[3];

  for i := 0 to 7 do                   { set up coordinate addresses }
    Addr[i] := RealX[i] + SW*RealY[i];

  asm
    mov ax, $A000
    mov es, ax                            { set up segment }
    xor di, di
  end;

  x := 0;                              { start with relative x = 0 }
  while (x <= y) do begin              { keep it up until octants meet }

    TempNeg := (D < 0);                { is decision var negative? }
    for i := 0 to 7 do begin           { process all eight pixels }

      if ((RealX[i]>=0) and (RealX[i]<=XMax) and           { clipping }
          (RealY[i]>=0) and (RealY[i]<=YMax)) then begin
    TempAddr := Addr[i];           { temp var for asm compatibility }
    asm                            { display pixel }
      mov di, TempAddr
      mov bl, Color
      mov es:[di], bl
        end end;

      addr[i] := Addr[i] + change[ord(tempneg)][i];        { update address }
      realx[i] := RealX[i] + changex[ord(tempneg)][i];     { update x }
      realy[i] := RealY[i] + changey[ord(tempneg)][i] end; { update y }

    if TempNeg then                   { if decision var is negative }
      D := D + (x shl 2) + 6          { D := D + 4*x + 6 }

    else begin                        { if decision va ris nonnegative }
      y := y - 1;                         { decrement y }
      D := D + ((x - y) shl 2) + 10; end;    { D := D * 4*(x-y) + 10 }

    x := x + 1; end
end;

