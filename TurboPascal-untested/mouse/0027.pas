{This is some really GOOD stuff,  Bravo Bas! }
Unit mouser;
{ Mouseunit for textmode. by Bas van Gaalen, Holland. }
{      Slight Additions/Removals by CJ Cliffe         }

Interface

Const
  mtypes : Array [0..4] Of String [6] = ('bus', 'serial', 'inport', 'ps/2', 'hp');
  
Var
  buttons : Word;
  verhi, verlo, mousetype : Byte;
  driverinstalled : Boolean;
  
Function mouseinstalled : Boolean;
Procedure resetmouse;
Procedure getmouseversion;
Procedure showmouse;
Procedure hidemouse;
Function getmousex : Byte;
Function getmousey : Byte;
Function leftpressed : Boolean;
Function rightpressed : Boolean;
Procedure mousewindow (X1, Y1, X2, Y2 : Byte);


Implementation


Function mouseinstalled : Boolean; Assembler; Asm
  XOr AX, AX
  Int 33h
  cmp AX, - 1
  je @skip
  XOr AL, AL
  @skip:
End;

Procedure resetmouse; Assembler;
Asm
  XOr AX, AX
  Int 33h
  cmp AX, - 1
  jne @skip
  mov driverinstalled, True
  mov buttons, BX
  @skip:
End;

Procedure getmouseversion; Assembler;
Asm
  mov AX, 24h
  Int 33h
  mov verhi, BH
  mov verlo, BL
  mov mousetype, CH
End;

Procedure showmouse; Assembler;
Asm
  mov AX, 1
  Int 33h
End;

Procedure hidemouse; Assembler;
Asm
  mov AX, 2
  Int 33h
End;

Function getmousex : Byte; Assembler;
Asm
  mov AX, 3
  Int 33h
  ShR CX, 1
  ShR CX, 1
  ShR CX, 1
  mov AX, CX
End;

Function getmousey : Byte; Assembler;
Asm
  mov AX, 3
  Int 33h
  ShR DX, 1
  ShR DX, 1
  ShR DX, 1
  mov AX, DX
End;

Function leftpressed : Boolean; Assembler;
Asm
  mov AX, 3
  Int 33h
  And BX, 1
  mov AX, BX
End;

Function rightpressed : Boolean; Assembler;
Asm
  mov AX, 3
  Int 33h
  And BX, 2
  mov AX, BX
End;

Procedure mousewindow (X1, Y1, X2, Y2 : Byte); Assembler;
Asm
  mov AX, 7
  XOr CH, CH
  XOr DH, DH
  mov CL, X1
  ShL CX, 1
  ShL CX, 1
  ShL CX, 1
  mov DL, X2
  ShL DX, 1
  ShL DX, 1
  ShL DX, 1
  Int 33h
  mov AX, 8
  XOr CH, CH
  XOr DH, DH
  mov CL, Y1
  ShL CX, 1
  ShL CX, 1
  ShL CX, 1
  mov DL, Y2
  ShL DX, 1
  ShL DX, 1
  ShL DX, 1
  Int 33h
End;

End.
