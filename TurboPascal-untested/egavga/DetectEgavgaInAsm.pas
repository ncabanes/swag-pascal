(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0095.PAS
  Description: Detect EGA/VGA in ASM
  Author: SWAG SUPPORT TEAM
  Date: 02-03-94  10:50
*)

program EGAORVGA;
{For TP 6.0 because of assembler code.  Put these functions into a UNIT
 for general use.}

  FUNCTION IsEGAorVGA : Boolean; Assembler;
  ASM
    MOV AH, 12h
    MOV BL, 10h
    INT 10h
    MOV AL, 0
    CMP BH, 1
    JA @Nope
    CMP BL, 3
    JA @Nope
    INC AL
    @Nope:
  END;

  FUNCTION IsVGA : Boolean; Assembler;
  ASM
    MOV AH, 12h
    MOV AL, 00h
    MOV BL, 36h
    INT 10h
    MOV AH, 0
    CMP AL, 12h
    JNZ @Nope
    INC AH
    @Nope:
  END;

begin
  If IsEGAorVGA then
  begin
    Writeln('Programs supporting EGA or VGA will run on this computer.');
    If IsVGA then
      Writeln('VGA detected.')
    Else
      Writeln('EGA detected.')
  end
  Else
      Writeln('No EGA or VGA detected!');
end.

