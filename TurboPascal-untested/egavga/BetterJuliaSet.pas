(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0088.PAS
  Description: Better Julia Set
  Author: BAS VAN GAALEN
  Date: 01-27-94  12:16
*)

{
>   Thanks for writing a working Pascal source.  Hopefully it will
>   work with 640x480 resolution (320x200 is a bit grainy, specieally
>   with the default palette.)

I changed Norbert's source a little. Now it looks nicer, and I believe it's
even a fraction faster (not sure, though, didn't time it):
}

{$G+,N+,E-} { if you have no CoPro, set E+ }

{ Reals   Complex
   -1        0
   -0.1      0.8
    0.3     -0.5
   -1.139    0.238
}

program Julia;
const Gseg : word = $a000;
Type real = double;
var Cx,Cy,Xo,Yo,X1,Y1 : real; Mx,My,A,B,I,Orb : word;

procedure Pset(X,Y : word; C : byte); assembler;
asm
  mov es,Gseg
  mov ax,[Y]
  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,[X]
  mov al,[C]
  mov [es:di],al
end;

function keypressed : boolean; assembler; asm
  mov ah,0bh; int 21h; and al,0feh; end;

procedure Setpalette;
var I : byte;
begin
  for I := 1 to 64 do begin
    port[$3c8] := I;
    port[$3c9] := 10+I div 3;
    port[$3c9] := 10+I div 3;
    port[$3c9] := 15+round(I/1.306122449);
  end;
end;

begin
  write('Real part: '); readln(Cx);
  write('Imaginary part: '); readln(Cy);
  asm mov ax,13h; int 10h; end;
  Setpalette;
  Mx := 319; My := 199;
  for A := 1 to Mx  do
    for B := 1 to My do begin
      Xo := -2+A/(Mx/4); { X complex plane coordinate }
      Yo :=  2-B/(My/4); { Y complex plane coordinate }
      Orb := 0; I := 0;
      repeat
        X1 := Xo*Xo-Yo*Yo+Cx;
        Y1 := 2*Xo*Yo+Cy;
        Xo := X1;
        Yo := Y1;
        inc(I);
      until (I = 64) or (X1*X1+Y1*Y1 > 4);
      if I <> 64 then Orb := I;
      Pset(A,B,Orb); { Plot orbit }
    end;
  while not keypressed do;
  asm mov ax,3; int 10h; end;
end.


