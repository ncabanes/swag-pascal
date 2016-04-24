(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0045.PAS
  Description: More File Handles
  Author: BRIAN GRAINGER
  Date: 01-27-94  17:43
*)

{
From: BRIAN GRAINGER               Refer#: NONE
Subj: Multiple open files            Conf: (58) Pascal
---------------------------------------------------------------------------
RL▒I would like to open 20-50 silumtaneous files (in TP 6.0 or 7.0).

Two ways that I know of. The first involves sleuthing around in the
Program Segment Prefix prepended to the memory image of a program's .EXE
file. This involves undocumented DOS calls, but is known to work.

The second is to use Interrupt 21h, Function 67h, Set Handle Count.
This is buggy in the original release of DOS 3.3, but is apparently
reliable in later versions.
}

USES
  Dos;

CONST
  LotsaHandles = 24861;

FUNCTION SetHandleCount(Count : WORD) : WORD;
  VAR
    Regs : Registers;
  BEGIN
    SetHandleCount := 0;
    WITH Regs DO
      BEGIN
        AH := $67;
        BX := Count;
        Intr($21, Regs);
        IF Flags AND fCarry <> 0 THEN (* Error?                *)
          SetHandleCount := AX;       (* AX returns error code *)
      END;
  END;

BEGIN
  IF SetHandleCount(LotsaHandles) <> 0 THEN
    WriteLn('Sorry. Better luck next time.')
  ELSE
    WriteLn('What do think I am, a mainframe?');
END.

{ ASSEMBLER TO DO THE SAME THING

(If you are not using protected mode you have to limit the use of DOS memory
by using compiler direvtive $M in BP. DOS steals the first 5 handles for std.
devices. This require at least DOS 3.3)
}


procedure SetHandleCount( wInAnt: WORD );
var
 err            : Boolean;
begin
asm

        MOV     AX, $6700;
        MOV     BX, wInAnt
        INT     $21
        MOV     err, 0
        JNC     @l1
        MOV     err, 1          { Error! }
@l1:
end;
  if err then begin
    ClrScr;
    writeln('Not enough memory');
    halt(0);
  end;
end;

