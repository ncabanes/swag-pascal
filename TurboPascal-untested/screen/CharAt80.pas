(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0068.PAS
  Description: Char At 80
  Author: ANDREW EIGUS
  Date: 08-24-94  13:54
*)

{
 SG> Anybody know how to place a character at 80,25 in text mode without
 SG> scrolling the screen?  TIA
}

USES Crt;

var
  ScreenHeight : byte;   { screen height in characters (rows) }
  ScreenWidth : word;    { screen width in characters (columns) }
  Screen : pointer;      { screen pointer }

{ some usef00l routines }

Function ScrReadChar(X,Y : BYTE) : CHAR; assembler;
Asm
  LES DI,Screen
  XOR AH,AH
  MOV AL,Y
  DEC AX
  MUL ScreenWidth
  SHL AX,1
  XOR DH,DH
  MOV DL,X
  SHL DX,1
  DEC DX
  DEC DX
  ADD AX,DX
  MOV DI,AX
  MOV AL,BYTE PTR [ES:DI]
  {ScrReadChar := Char(Ptr(Seg(Screen^),
    (Y - 1) * ScreenWidth * 2 + (X * 2) - 2)^)}
End; { ScrReadChar }

Procedure ScrWriteChar(X,Y : BYTE; Ch : CHAR); assembler;
Asm
  LES DI,Screen
  XOR AH,AH
  MOV AL,Y
  DEC AX
  MUL ScreenWidth
  SHL AX,1
  XOR DH,DH
  MOV DL,X
  SHL DX,1
  DEC DX
  DEC DX
  ADD AX,DX
  MOV DI,AX
  MOV AL,Ch
  MOV BYTE PTR [ES:DI],AL
  {Char(Ptr(Seg(Screen^),
    (Y - 1) * ScreenWidth * 2 + (X * 2) - 2)^) := Ch}
End; { ScrWriteChar }

Function ScrReadAttr(X,Y : BYTE) : BYTE; assembler;
Asm
  LES DI,Screen
  XOR AH,AH
  MOV AL,Y
  DEC AX
  MUL ScreenWidth
  SHL AX,1
  XOR DH,DH
  MOV DL,X
  SHL DX,1
  DEC DX
  ADD AX,DX
  MOV DI,AX
  MOV AL,BYTE PTR [ES:DI]
  {ScrReadAttr := TTextAttr(Ptr(Seg(Screen^),
    (Y - 1) * ScreenWidth * 2 + (X * 2) - 1)^)}
End; { ScrReadAttr }

Procedure ScrWriteAttr(X,Y,Color : BYTE); assembler;
Asm
  LES DI,Screen
  XOR AH,AH
  MOV AL,Y
  DEC AX
  MUL ScreenWidth
  SHL AX,1
  XOR DH,DH
  MOV DL,X
  SHL DX,1
  DEC DX
  ADD AX,DX
  MOV DI,AX
  MOV AL,Color
  MOV BYTE PTR [ES:DI],AL
  {TTextAttr(Ptr(Seg(Screen^),
    (Y - 1) * ScreenWidth * 2 + (X * 2) - 1)^) := Color}
End; { ScrWriteAttr }

{ and finally in your program... }

Begin
  { initialize ScreenHeight, ScreenWidth and Screen... }
  if LastMode = Mono then
    Screen := Ptr($B000, 0) else Screen := Ptr($B800, 0);
  if (LastMode and Font8x8) <> 0 then
    ScreenHeight := Mem[$0040:$0084] else ScreenHeight := 25;
  ScreenWidth := MemW[$0040:$004A];

  { do whatever you want, for example: }
    ScrWriteChar(ScreenWidth, ScreenHeight, 'A');
    ScrWriteAttr(ScreenWidth, ScreenHeight, LightGray );

End.


