(*
  Category: SWAG Title: COMMAND LINE ROUTINES
  Original name: 0006.PAS
  Description: Kill Underscore
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:34
*)

{
This is another BAsm I've written to optimize my Program. Some of the
comma-delimited fields have the Underscore Character in the place of Spaces. It
is desirable For them to be replaced For use in my Program.

BeFore writing this Procedure I was using:

Procedure Kill_(Var Strng : String);
Repeat
  Subpos := Pos('_',String);
  if subpos > 0
     then Strng[subpos] := ' ';
Until Killpos Subpos = 0;
end;

This was getting called approx 250,000 times in my project, and Turbo ProFiler
practically waved a red flag at me about it!  <grin>

This is my new Procedure which screams as Compared to the previous routine.

I am using TP 6.0 Professional.

-------------  Code Snippet begins  --------------
}
Procedure KILL_(Var STRNG); Assembler;
{ This Procedure KILLS Underscores from a String _and MODifIES THE orIGinAL_ }
Asm
  LES DI, STRNG
  xor CX, CX
  MOV CL, [ES:DI] { Get String Length}
  MOV AL, '_'
  inC DI  { Point to FIRST String Char }
  CLD
@Scan_For_underscore_loop:
  SCASB
  JE @FOUND_UNDERSCorE
  LOOP @SCAN_For_UNDERSCorE_LOOP
  JMP @OUTTATHIS
@FOUND_UNDERSCorE:
  DEC DI
  MOV Byte PTR [ES:DI], ' '
  inc di
  jmp @scan_For_underscore_loop
(92 min left), (H)elp, More? @OUTTATHIS:
end;

{
Does anyone more knowledgable in Assembly than I am have any suggestions For
this Procedure?   I Realize I am working With the original copy of the String
with this Procedure, and modifying it to boot, but I am saving the time to copy
it to/from the stack when I am making the changes.    My Program doES take this
into account, and ONLY passes Strings to the procedure.
}

