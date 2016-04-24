(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0018.PAS
  Description: Stack Usage Report
  Author: STEVE ROGERS
  Date: 06-08-93  08:28
*)

(*
===========================================================================
 BBS: Canada Remote Systems
Date: 05-30-93 (08:25)             Number: 8026
From: STEVE ROGERS                 Refer#: NONE
  To: PAUL HICKEY                   Recvd: NO  
Subj: HELP PLEASE                    Conf: (1617) L-PASCAL
---------------------------------------------------------------------------
PH> EP> {$M $A,B,C}

PH> I always set A and B to high and C to 0.  I want to allow the most memory I
PH>can to program usage within the 640K limit.

  To get the most ram for your prog to use in the 640k set "B" to 0
  and "C" to 655360. Setting "C" to 0 prevents you from accessing any
  heap at all.

  "A" should be set to the amount of stack your program needs. I have a
  unit that I use to help determine this. It was initially released for
  TP4 but I've used with BP7 OK.

{***********************************************************
  StackUse - A unit to report stack usage information

  by Richard S. Sadowsky
  version 1.0 7/18/88
  released to the public domain

  Inspired by a idea by Kim Kokkonen.

  This unit, when used in a Turbo Pascal 4.0 program, will
  automatically report information about stack usage.  This is very
  useful during program development.  The following information is
  reported about the stack:

  total stack space
  Unused stack space
  Stack spaced used by your program

  The unit's initialization code handles three things, it figures out
  the total stack space, it initializes the unused stack space to a
  known value, and it sets up an ExitProc to automatically report the
  stack usage at termination.  The total stack space is calculated by
  adding 4 to the current stack pointer on entry into the unit.  This
  works because on entry into a unit the only thing on the stack is the
  2 word (4 bytes) far return value.  This is obviously version and
  compiler specific.

  The ExitProc StackReport handles the math of calculating the used and
  unused amount of stack space, and displays this information.  Note
  that the original ExitProc (Sav_ExitProc) is restored immediately on
  entry to StackReport.  This is a good idea in ExitProc in case a
  runtime (or I/O) error occurs in your ExitProc!

  I hope you find this unit as useful as I have!

************************************************************)

{$R-,S-} { we don't need no stinkin range or stack checking! }
unit StackUse;

interface

var
  Sav_ExitProc     : Pointer; { to save the previous ExitProc }
  StartSPtr        : Word;    { holds the total stack size    }

implementation

{$F+} { this is an ExitProc so it must be compiled as far }
procedure StackReport;

{ This procedure may take a second or two to execute, especially }
{ if you have a large stack. The time is spent examining the     }
{ stack looking for our init value ($AA). }

var
  I                : Word;

begin
  ExitProc := Sav_ExitProc; { restore original exitProc first }

  I := 0;
  { step through stack from bottom looking for $AA, stop when found }
  while I < SPtr do
    if Mem[SSeg:I] <> $AA then begin
      { found $AA so report the stack usage info }
      WriteLn('total stack space : ',StartSPtr);
      WriteLn('unused stack space: ', I);
      WriteLn('stack space used  : ',StartSPtr - I);
      I := SPtr; { end the loop }
    end
    else
      inc(I); { look in next byte }
end;
{$F-}


begin
  StartSPtr := SPtr + 4; { on entry into a unit, only the FAR return }
                         { address has been pushed on the stack.     }
                         { therefore adding 4 to SP gives us the     }
                         { total stack size. }
  FillChar(Mem[SSeg:0], SPtr - 20, $AA); { init the stack   }
  Sav_ExitProc := ExitProc;              { save exitproc    }
  ExitProc     := @StackReport;          { set our exitproc }
end.

