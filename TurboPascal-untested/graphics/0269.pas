{If you have any questions please send me mail at OleRom@hotmail.com}
{3d wavig flag}
{--------------------------------}
{ Copyright by Bostjan Gabrovsek }
{--------------------------------}
Program Rulz;
Const SloFake : Array[1..17,1..50] of Byte = (
(2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,2,3,1,1,1,1,1,1,1,2,2,3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,2,3,1,1,1,1,1,1,2,2,2,2,1,2,3,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,2,3,1,4,4,1,1,2,2,2,2,2,1,2,2,3,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,2,3,1,4,4,1,1,1,2,2,2,2,2,1,2,2,3,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,3,1,1,1,1,1,1,1,2,2,2,2,2,1,2,2,3,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,3,1,1,1,1,1,1,2,2,2,2,2,1,2,2,1,2,3,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,3,1,4,4,1,1,2,2,2,2,2,2,1,2,2,1,2,2,3,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,3,1,4,4,1,1,2,2,2,2,2,2,2,1,2,2,1,2,3,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,3,1,1,1,1,1,1,2,2,2,2,2,2,1,2,2,1,3,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,3,1,1,1,1,1,1,1,2,2,2,2,1,2,2,1,3,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,2,3,1,4,4,1,1,1,2,2,2,2,1,2,2,1,3,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,2,3,1,4,4,1,1,2,2,2,2,2,2,1,1,3,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,2,3,1,1,1,1,1,1,2,2,2,2,2,1,3,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,2,3,1,1,1,1,1,1,1,2,2,3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
(2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3));
Type SloType = array[1..80,1..50] of Byte;
     ScreenType = Array[1..200,1..320] of Byte;
     SloPointType = array[1..80,1..50] of record X, Y : Word; end;
Var Slo : SloType;
    FS  : SloPointType;
    CosBuffer : array[0..63] of ShortInt;
    Sk: ^ScreenType;
    Fo, Ka : Byte;
    X, Y, Fx, Fy, Cnt : Word;
Procedure SetPal(Color,R,G,B:Byte);
Begin
 Port[$3C8] := Color;
 Port[$3C9] := R;
 Port[$3C9] := G;
 Port[$3C9] := B;
End;
Function KeyPressed:boolean;
Begin
 KeyPressed := Mem[$40:$1C] - Mem[$40:$1A] <> 0;
end;
Begin {Telo programa}
WriteLn('Copyright by Boτtjan Gabrovτek'); WriteLn;
 New(Sk);
 Ka := 0;
While (Char(Ka) < '1') or (Char(Ka) > '5') do
 Begin
  Write('Enter Waving 1 - 5 : ');
  ReadLn(Char(Ka));
 End;
 Ka := Ka - Byte('1') + 7;
asm mov ax,19; int 10h; end;
For Fo := 1 to 80 do Move(SloFake[17],Slo[Fo],50);
For Fo := 1 to 17 do Move(SloFake[Fo],Slo[Fo+5],50);
For Fo := 1 to 64 do CosBuffer[Fo-1] := Round(Cos(Fo/10)*Ka);
For Fo := 1  to 31 do SetPal(Fo,0,0,Fo*2-10);
For Fo := 32 to 63 do SetPal(Fo,(Fo-32)*2-10,(Fo-32)*2-10,(Fo-32)*2-10);
For Fo := 64 to 95 do SetPal(Fo,(Fo-64)*2-10,0,0);
For Fo := 96 to 127 do SetPal(Fo,(Fo-96)*2-10,(Fo-96)*2-10,0);
 Cnt := 0;
Repeat
Inc(Cnt,2);
FillChar(Sk^,64000,0);
FillChar(Fs,850*2,0);
For X := 1 to 80 do
 For Y := 1 to 50 do
  Begin
   Fs[X,Y].Y := 20+Y*3+CosBuffer[(X+Y+Cnt) mod 64];
   Fs[X,Y].X := 40+X*3+CosBuffer[(Y+X+Cnt) mod 64];
    For Fx := Fs[X-1,Y].X to Fs[X,Y].X-1 do
     For Fy := Fs[X,Y-1].Y to Fs[X,Y].Y-1 do Sk^[Fy,Fx] := (SLO[X,Y])*32 - CosBuffer[(X+Y+Cnt) mod 64] - 12;
  End;
asm cli; mov bx,ds; lds si,Sk; mov ax,0A000h; mov es,ax;
xor di,di; mov cx,32000; REP movsw; mov ds,bx; sti; end;
Until KeyPressed;
asm mov ax,3; int 10h; end;
 Dispose(Sk);
WriteLn('Copyright by Boτtjan Gabrovτek'); WriteLn;
End.