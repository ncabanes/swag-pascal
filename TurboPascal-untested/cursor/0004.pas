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