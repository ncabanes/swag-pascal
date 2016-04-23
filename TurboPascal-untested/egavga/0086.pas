program Julia;
{program computes and displays a Julia Set using VGA 256 color graphics in
 mode 13h.  written by Andrew Key and released to the public domain.  not
 guaranteed -- use at own risk (but it has been put through limited tests...)
 }
uses
  Crt;

const
  MX = 100;  {horizontal number of pixels}
  MY = 100;  {vertical num. of pixels}

type
  Complex = record                           {Data type for complex numbers}
              A,Bi: real;
            end;
  VGAMemType = array[1..200,1..320] of byte; {addressed y,x}

var
  Num, C: Complex;
  X,Y,SaveMode,I: integer;
  ch: char;
  VGAMem : VGAMemType Absolute $A000:$0000;  {accesses actual video memory}

procedure SetMode(mode: integer); assembler; {sets video card to specified
                                              mode}
  asm
    mov ax,mode
    int $10            {Video interrupt}
  end;

function CurrentMode: integer; assembler;    {returns current video mode}
  asm
    mov ax,$0f00
    int $10
    xor ah,ah
  end;

procedure SqCplx(var N: complex);  {squares a variable of type Complex)}
  var
    temp: real;
  begin
    temp:= (N.A * N.A) - (N.Bi * N.Bi);
    N.Bi:= 2 * N.A * N.Bi;
    N.A:= temp;
  end;

procedure AddCplx(var X: complex; Y: complex);
{Adds two complex variables -- X := X + Y}
  begin
    X.A := X.A + Y.A;
    X.Bi:= X.Bi + Y.Bi;
  end;

function SqDist(X: complex): real;
{Computes the square of the distance from the point X to the origin}
  begin
    SqDist := X.A * X.A + X.Bi * X.Bi;
  end;

procedure ClrVidScr; {Clears video screen in mode 13h}
  var x,y: integer;
  begin
    for x:=1 to 320 do
      for y:=1 to 200 do
        VGAMem[y,x]:=0;
  end;

begin
  {Get values for complex constant}
  ClrScr;
  write('Real part: ');
  readln(C.A);
  write('Imaginary part: ');
  readln(C.Bi);

  {set video mode to 320*200*256 VGA and clear screen}
  SaveMode:= CurrentMode;  {save current mode}
  SetMode($13);            {set mode 13h}
  ClrVidScr;

  {compute julia set}
  for y:= 0 to (MY-1) do
    for x:= 0 to (MX-1) do
      begin
        Num.A := -2 + x / ( MX / 4);  {compute REAL component}
        Num.Bi:= 2 - y / ( MX / 4);   {compute IMAGINARY component}
        I:=0;                         {reset number of iterations}
        repeat
          SqCplx(Num);                {square the complex number}
          AddCplx(Num,C);             {and add the complex constant}
          Inc(I);
        until ((I>=255) or (SqDist(Num)>4));
        VGAMem[y+1,x+1]:=I;           {plot the point}
      end;

  {julia set completed}
  ch:=readkey;                        {wait for a keypress}
  SetMode(SaveMode);                  {return to original mode}
end.
