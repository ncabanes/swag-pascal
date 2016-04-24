(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0001.PAS
  Description: Convert ASCIIZ to Turbo
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:58
*)

Function Asc2Str(Var s; Max : Byte): String;
{ Converts an ASCIIZ String to a Turbo Pascal String }
{ With a maximum length of max.                      }
Var
  StArray  : Array[1..255] of Char Absolute s;
  Len      : Integer;
begin
  Len        := Pos(#0,StArray)-1;                       { Get the length }
  if (Len > Max) or (Len < 0) then               { length exceeds maximum }
    Len      := Max;                                  { so set to maximum }
  Asc2Str    := StArray;
  Asc2Str[0] := Chr(Len);                                    { Set length }
end;  { Asc2Str }

