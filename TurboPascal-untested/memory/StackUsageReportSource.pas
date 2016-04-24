(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0051.PAS
  Description: Stack usage report source
  Author: ERIK DE NEVE
  Date: 05-25-94  08:23
*)

{
The program StackUse below measures your EXACT stack usage
(REAL mode only). Make sure the constant Ssize is equal to the
actual physical stack size as defined with the $M directive or
in the Turbo Pascal IDE settings (the Options/MemorySizes menu).

For your own programs, you just need to call Initstack at the very
start, then call StackReport whenever you want - or calculate for
yourself, (Ssize-(VirginStack-StackLimit)) equals the number of
stack bytes actually used.

Sptr gives you the current stack pointer, and StackLimit is
a TP system variable (WORD) that contains the current bottom of
of the stack. StackLimit is usually zero, but some 'sneaky'
programs raise it so they can hide something there - for example,
c1;0compiling your program using the replacement run-time libraries
by Norbert Juffa can raise the StackLimit to 512.
The stack is filled from top to bottom, so a stack overflow
means Sptr <= StackLimit.
UseStack is just an example of a procedure that makes heavy
use of the stack.

This code can be freely included in any FAQ,
SNIPPETS, SWAG or what-have-you.

 Erik de Neve
 Internet:    100121.1070@compuserve.com

 Last update:  March  8, 1994

{ -*- CUT HERE -*- }

Program StackUse;

{$M 16384,0,0 }

CONST
 Ssize = 16384; {should match stack size as set by the $M directive }

Procedure Initstack;  { fills unused stack with marker value }
 Assembler;
 ASM
   PUSH SS      { SS = the stack segment }
   POP  ES
   MOV  DI,StackLimit
   MOV  CX,SP    { SP = stack pointer register }
   SUB  CX,DI
   MOV  AL,77    { arbitrary marker value }
   CLD
   REP  STOSB
 END;

Function VirginStack:word;  { finds highest unused byte on stack }
 Assembler;
 ASM
   PUSH SS
   POP  ES
   MOV  DI,StackLimit   { is usually 0 }
   MOV  CX,SP
   SUB  CX,DI
   MOV  AL,77  { marker value, must be the same as in InitStack }
   CLD
   REPE SCASB  { scan empty stack }
   DEC  DI     { adjust for last non-matching byte in the scan }
   MOV  AX,DI
 END;


Procedure StackReport; { Reports all sizes in bytes and percentages }
begin
 WriteLn('Stack Bottom : ',StackLimit:6);
 WriteLn('Current SP   : ',Sptr:6);
 WriteLn('Total Stack  : ',Ssize:6,
 ' bytes   = 100.00 %');
 WriteLn('  Now used   : ',Ssize-(Sptr-StackLimit):6,
 ' bytes   = ',(Ssize-(Sptr-StackLimit))/Ssize *100:6:2,' %');
 WriteLn(' Ever used   : ',Ssize-(VirginStack-StackLimit):6,
 ' bytes   = ',(Ssize-(VirginStack-StackLimit))/Ssize *100:6:2,' %');
 WriteLn('Never used   : ',(VirginStack-StackLimit):6,
 ' bytes   = ',(VirginStack-StackLimit)/Ssize *100:6:2,' %');
end;


Procedure UseStack(CNT:WORD); Assembler;  { example stack usage }
 ASM
   MOV  AX,0    {dummy value}
   MOV  CX,CNT
@pushit:        {perform CNT PUSHes}
   PUSH AX
   LOOP @pushit
   MOV  CX,CNT
@poppit:        {perform CNT POPs}
   POP  AX
   LOOP @poppit
 END;


BEGIN
 InitStack;      { prepare stack }
 UseStack(1000); { perform a number of PUSHes and POPs }
 StackReport;    { report stack usage }
END.

