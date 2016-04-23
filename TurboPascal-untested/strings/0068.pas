{
 > Really need an inline macro to add a character to the end of a string.
How 'bout this one (from my book, of course):
}

Procedure AddStr14(Var Str : String; C : Char);
InLine(
  $58/            {    POP   AX            ; get chr C in AX }
  $5F/            {    POP   DI            ; pop offset Str  }
  $07/            {    POP   ES            ; pop segment Str }
  $26/            {    ES:                 }
  $FE/$05/        {    INC   BYTE PTR [DI] ; inc length byte }
  $31/$DB/        {    XOR   BX,BX         }
  $26/            {    ES:                 }
  $8A/$1D/        {    MOV   BL,[DI]       ; get length byte }
  $01/$DF/        {    ADD   DI,BX         ; goto end of str }
  $AA);           {    STOSB               ; add character C }

Var
  Str : String;

begin
  Str := 'Bob';
  AddStr14(Str, ' ');
  AddStr14(Str, 'S');
  AddStr14(Str, 'w');
  AddStr14(Str, 'a');
  AddStr14(Str, 'r');
  AddStr14(Str, 't');
  WriteLn(Str)
end.

