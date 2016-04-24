(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0280.PAS
  Description: Fast 3D Wavig Flag
  Author: BOSTJAN GABROVSEK
  Date: 08-30-97  10:09
*)

{If you have any questions please send me mail at OleRom@hotmail.com}
{Fast 3d wavig flag}
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
     SloPointType = array[1..80,1..50] of
      RECORD
       C    : Byte;
       X, Y : Word;
      end;
Var Slo : SloType;
    FS  : SloPointType;
    CosBuffer : array[0..63] of ShortInt;
   {S : ScreenType absolute $A000:$0000;}
    Sk: ^ScreenType;
    Fo : Byte;
    X, Y : Word;
    Cnt : Word;
    P : ^ScreenType;
    Mm : Byte;
Procedure MoveDATA; assembler;
asm
 cli
 mov bx,ds
 lds si,Sk
 mov ax,0A000h
 mov es,ax
 xor di,di
 mov cx,32000
 REP movsw
 mov ds,bx
 sti
end;
Procedure SetGraph;assembler;
asm
  mov ax,4F02h
  mov bx,0101h
  mov ax,13h
  int 10h
end;
Procedure CloseGraph;assembler;
asm
  mov ax,0003h
  int 10h
end;
Procedure TurnScreenOn; assembler;
asm
  mov dx,03C4h
  mov al,1
  out dx,al
  inc dx
  xor al,al
  out dx,al
end;
Procedure TurnScreenOff; assembler;
asm
  mov dx,03C4h
  mov al,1
  out dx,al
  inc dx
  in al,dx
  or al,20h
  out dx,al
end;
Procedure SetPal(Color,R,G,B:Byte); assembler;
asm
  mov dx,03C8h
  mov al,[Color]
  out dx,al
  inc dx
  mov al,[R]
  out dx,al
  mov al,[G]
  out dx,al
  mov al,[B]
  out dx,al
end;
Function KeyPressed:boolean; assembler;
asm
  mov bx,40h
  mov es,bx
  mov ax,word ptr es:[001Ch]
  sub ax,word ptr es:[001Ah]
end;
Procedure Delay(ms:word);assembler;
asm
  mov ax,1000
  mul ms
  mov cx,dx
  mov dx,ax
  mov ah,86h
  int 15h
end;
Begin
 New(Sk);
 SetGraph;
For Fo := 1 to 80 do
  Move(SloFake[17],Slo[Fo],50);
For Fo := 1 to 17 do
 Move(SloFake[Fo],Slo[Fo+5],50);
For Fo := 1 to 64 do CosBuffer[Fo-1] := Round(Cos(Fo/10)*11);
For Fo := 0  to 63  do SetPal(Fo,0,0,Fo);
For Fo := 64 to 127 do SetPal(Fo,Fo-64,Fo-64,Fo-64);
For Fo := 128 to 191 do SetPal(Fo,Fo-128,0,0);
For Fo := 192 to 255 do SetPal(Fo,Fo-192,Fo-192,0);
 Cnt := 0;

Repeat
Inc(Cnt,2);
FillChar(Sk^,64000,0);
FillChar(Fs,850*3,0);
{For X := 1 to 80 do
 For Y := 1 to 50 do
  Sk^[20+Y*3+CosBuffer[(X+Y+Cnt) mod 64],40+X*3+CosBuffer[(Y+X+Cnt) mod 64]] :=
  (SLO[X,Y])*63 - CosBuffer[(X+Y+Cnt) mod 64]*2 - 22;}
For X := 1 to 80 do
 For Y := 1 to 50 do
  Begin
   Fs[X,Y].C := (SLO[X,Y])*63 - CosBuffer[(X+Y+Cnt) mod 64]*2 - 22;
   Fs[X,Y].Y := 20+Y*3+CosBuffer[(X+Y+Cnt) mod 64];
   Fs[X,Y].X := 40+X*3+CosBuffer[(Y+X+Cnt) mod 64];
  End;
For X := 1 to 80 do
 For Y := 1 to 50 do
  Sk^[Fs[X,Y].Y,Fs[X,Y].X] := Fs[X,Y].C;
MoveDATA;
Until KeyPressed;
CloseGraph;
 Dispose(Sk);
End.

