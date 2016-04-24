(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0051.PAS
  Description: Flushing Fossil Buffers
  Author: JOHN STEPHENSON
  Date: 08-24-94  13:52
*)


Procedure PurgeInput; assembler;
{ Purges the input buffer -- Empties it into obilivion! }
asm
  mov AH, $0A
  mov DX, port
  Int $14
End;




