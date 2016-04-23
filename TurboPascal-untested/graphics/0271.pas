{If you have any questions please send me mail at OleRom@hotmail.com}
Uses Graph, Crt;
Var X, Y : Word;
    R : ShortInt;
    Xx : Array[1..10] of Word;
    C : Array[1..10] of Byte;
    W : Array[1..10] of Word;
    B : Byte;
    S : String[1];
Procedure SetGraph;
{$F+} Function DETECTSvga : Integer; assembler; {$F-} asm mov ax,0002h end;
Var GDr : Integer;
Begin
 GDr := InstallUserDriver('SVGA256',@DETECTSvga);
 GDr := DETECT;
 InitGraph(GDr,GDr,'');
End;
Procedure SetPal(Color,R,G,B:Byte); assembler;
asm
  mov dx,03C8h; mov al,[Color]; out dx,al
  inc dx; mov al,[R]; out dx,al
  mov al,[G]; out dx,al; mov al,[B]; out dx,al
end;
Begin
SetGraph;
For B := 1 to 63 do SetPal(B,B,B,B div 3);
Repeat
ClearDevice;
For B := 1 to 10 do C[B] := Random(63);
 X := GetMaxX div 2;
 For B := 1 to 10 do W[b] := Random(300)-150+GetMaxY div 2;
 For Y := 00 to GetMaxY do
  Begin
   For B := 1 to 10 do
    If Y = W[B] then Xx[B] := X;
   If Y mod 10 = 0 then R := Random(3)-1;
   X:=X+R;
   X:=X+Random(3)-1;
   PutPixel(X,Y,63);
   PutPixel(X+1,Y,23);
   PutPixel(X-1,Y,23);
  End;
For B := 1 to 10 do
Begin
 X := Xx[B];
 For Y := w[b] to W[b] + Random(200) do
  Begin
   If Y mod 10 = 0 then R := Random(3)-1;
   X:=X+R+Random(3)-1;
   If Odd(Y) then
    If Odd(B) then Inc(X) else Dec(X);
   PutPixel(X,Y,C[B]);
  End;
End;
{ ReadLn(S);}
Until Port[$60] = 1;
NOSound;
End.