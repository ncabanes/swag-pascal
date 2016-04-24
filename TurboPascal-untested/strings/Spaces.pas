(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0006.PAS
  Description: SPACES.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:58
*)

Function Spaces(NumSpaces : Byte) : String;

Var
  s : String;

begin
  s[0] := Chr(Numspaces);
  If NumSpaces = 0 Then
    Exit;
  FillChar(s[1], NumSpaces, ' ');
  Spaces := s;
end;

{
This still too slow For my taste, though...  there's a superfluous String
copy and it still needs 512 Bytes of stack space.
}

Function Spaces(NumSpaces : Byte) : String; Assembler;

Asm
  LES    DI, @Result
  CLD
  MOV    AL, NumSpaces
  xor    AH, AH
  STOSB
  XCHG   AX, CX
  JCXZ   @Exit
  MOV    AL, ' '
  SHR    CX, 1
  JNC    @Even
  STOSB
@Even:  REP    STOSW
@Exit:
end;  { Spaces }

