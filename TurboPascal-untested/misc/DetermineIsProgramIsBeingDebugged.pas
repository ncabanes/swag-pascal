(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0113.PAS
  Description: Determine is program is being debugged!
  Author: WILLEM JOOSTEN
  Date: 11-26-94  05:07
*)

{
>> Does any body have source code to tell me if my program
>> is being debugged with TURBO DEBUGGER. ?

It is possible to detect if your program is debugged. Debuggers use interrupt 3
for breakpoints. The following example will simply crash the program if its run
with Turbo Debugger, under DOS there's no problem.

CAUTION : this program wil crash if run under a debugger, including the
          IDE (when you make use of breakpoints)
}

Program DebugTest ;
Uses
  DOS ;
var
  OldInt3 : Pointer ;
{$F+}

Procedure Int3 ; assembler ;
ASM
end ;

Begin
  GetIntVec (3, OldInt3) ;
  SetIntVec (3, @int3) ;
  { Put breakpoint here }
  Writeln ('Breakpoint action ?') ;
  SetIntVec (3, OldInt3) ;
end.

