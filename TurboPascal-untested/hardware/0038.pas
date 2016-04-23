{
>>> Well, I have it now: the program was compiled in G+ mode (enable
>>> 286-instructions) and it therefore bombed on an 8088 or 8086
>>> machine. Too bad it didn't do so graciously with a proper error.

I've thrown together this little unit here - if your program or unit uses
$G+, just add this as the FIRST! unit in the USES clause. It is called
_286.PAS:
}

(*
  Programs compiled with {$G} compiler directive enabled do not
  check the processor at runtime to determine whether it is
  286-compatible. Trying to execute 80286 instructions on an 8086
  or an 8088 will lock up the computer. This program checks
  for the presence of a 286-compatible chip at runtime.

  Put this unit as the FIRST in the USES clause.
*)

Unit _286;

Interface

Implementation

function Is286Able : Boolean; assembler;
asm
  PUSHF
  POP     BX
  AND     BX,0FFFH
  PUSH    BX
  POPF
  PUSHF
  POP     BX
  AND     BX,0F000H
  CMP     BX,0F000H
  MOV     AX,0
  JZ      @@1
  MOV     AX,1
 @@1:
end;

begin
  if not Is286Able then
  begin
    Writeln('Need an 80286-compatible system to run this program');
    Halt(1);
   end;
end.

{--------------------- CUT HERE ------------------}

{
 This can be put in individual units, just make sure it is the FIRST
 unit in the USES clause, eg

  Uses
    _286,
    Crt,
    Dos,
    KeyTTT5;
}
