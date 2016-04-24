(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0032.PAS
  Description: Simple & QUICK Graphics
  Author: STEVE BOUTILIER
  Date: 11-02-93  04:50
*)

{ STEVE BOUTILIER }

Uses
  Dos,
  Crt;

Procedure OpenGraphics; Assembler;
Asm
  Mov Ah, 00h
  Mov Al, 13h
  Int $10
end;

Procedure CloseGraphics; Assembler;
Asm
  Mov Ah, 00h
  Mov Al, 03h
  Int $10
end;

Procedure PutXY(X, Y : Byte); Assembler;
Asm
  Mov Ah, 02h
  Mov Dh, Y - 1
  Mov Dl, X - 1
  Mov Bh, 0
  Int $10
end;

Procedure OutChar(S : Char; Col : Byte); Assembler;
Asm
  Mov Ah, 0Eh
  Mov Al, S
  Mov Bh, 0
  Mov Bl, Col
  Int $10
end;

Procedure OutString(S : String; Col : Byte);
Var
 I  : Integer;
 Ch : Char;
begin
  For I := 1 to Length(s) do
  begin
   Ch := S[I];
   OutChar(Ch, Col);
  end;
end;

begin
  OpenGraphics;
  OutString('HELLO WORLD!' + #13#10, 14);
  Repeat Until KeyPressed;
  CloseGraphics;
end.

{
BTW: This code is Public Domain! Do what you want With it! most of you
     probably already have routines that are even better than this.
}


