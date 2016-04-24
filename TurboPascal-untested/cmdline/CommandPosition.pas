(*
  Category: SWAG Title: COMMAND LINE ROUTINES
  Original name: 0007.PAS
  Description: Command Position
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:34
*)

{
I have two BAsm Procedures I have written to speed up a Program which scans a
comma delimited line.    My testing has shown 50,000 iterations of this
Function to be approx 3 seconds faster than TP's  Var := Pos(',',String);

I am fairly new to Assembly.   This Function doES in fact work, but not as fast
as I feel it should.    Can anyone see any places I have gone wrong in speed?
I've avoided copying the String to the stack, by just declaring a Pointer
Variable as the Function's input.  I'd like to squeeze a couple more seconds
out of it if I could.   The Procedures will deal With about 6 megs of data all
on comma delimited lines.

I suppose I COULD speed it up, by not declaring ANY Variable, and hard-code it
to specifically use the String Variable I am currently passing to it.
 }

Function Commapos(Var STRNG) : Byte; Assembler; Asm
 LES DI, STRNG     { Point ES:DI to beginning of STRNG }
 xor CH, CH        { Just in Case anything is in Register CH }
 MOV CL, [ES:DI]   { Load String Length into CL }
 MOV AH, CL        { Save len to Compute commapos later }
 inC DI            { Point to First Char in String }
 MOV AL, ','       { Looking For Comma }
 CLD
@SCANForCOMMALOOP:
 SCASB             { Compare [ES:DI] to contents of AL, inc DI, Dec CL}
 JE @FOUND_COMMA   { Found a Comma! }
 LOOP @SCANForCOMMALOOP  { No Such Luck! }
 MOV AL, 0         { Loop Fell through, no comma exists, set position to 0 }
 JMP @OUTTAHERE    { JumpOut of Loop and Exit } @FOUND_COMMA:
 DEC CL            { Reduce by one, since DI was advanced past the comma }
 SUB AH, CL        { Subtract CL from AH to give the position }
 MOV AL, AH        { Put the result into AL to return to Turbo } @OUTTAHERE:
end;

