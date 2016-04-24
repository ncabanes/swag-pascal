(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0004.PAS
  Description: Show/Hide Cursor
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:36
*)

Uses Crt;

Var
  Continue : Char;

Procedure HideCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$2607
  INT   $10
end;

Procedure ShowCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$0506
  INT   $10
end;

begin
  Writeln('See the cursor ?');
  Continue := ReadKey;
  HideCursor;
  Writeln('Gone! ');
  Continue := ReadKey;
  ShowCursor;
end.
