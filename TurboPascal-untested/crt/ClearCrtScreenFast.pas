(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0003.PAS
  Description: Clear CRT Screen FAST
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:36
*)

{
>Does anyone know how to clear the screen Really fast ?
Well, here is some Asm code but I haven't tested it. It should work:
}

Procedure FastClrScr; Assembler;
Asm
  MOV AH,0Fh
  INT 10h
  MOV AH,0
  INT 10h
end;

begin
  FastClrScr;
end.
