(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0035.PAS
  Description: Timer unit
  Author: CHRIS AUSTIN
  Date: 11-22-95  13:32
*)


Unit Timer;
 Interface
  Var Int1CSave : Procedure;        {Pointer to the old 1C.                  }
      TimerCnt  : Word;             {The timer counter.                      }

Procedure InstallInt1C;            {Install the interrupt routine for $1C.   }
Procedure RestoreInt1C;            {Restore the original interrupt for $1C.  }
Procedure SetTimer(SetVar : Word); {Sets the timer to a number of ticks.     }
Procedure WaitTimer;               {Waits until the timer is 0.              }
Procedure DLay(Ticks : Word);      {Delays a number of ticks (18.2 per sec.) }
Procedure DLaySec(Ticks : Word);   {Delays a certain # of seconds.           }
Function TimerDone : Boolean;      {Checks if the timer has counted down.    }
Implementation
 Uses CRT,
      DOS;

{$F+,S-}
Procedure TimerHandler;
 Interrupt;
  Assembler;
   Asm
    Cmp   TimerCnt,0
    Jle   @Done
    Dec   TimerCnt
   @Done:
    PushF
    Call  Int1CSave
   End;
{$F-,S-}

Procedure SetTimer(SetVar : Word); Begin TimerCnt:=SetVar End;

Function TimerDone : Boolean; Begin TimerDone:=TimerCnt=0; End;

Procedure WaitTimer;
 Assembler;
  Asm
   @RepLoop:
   Cmp TimerCnt,0
   Jge @RepLoop
  End;

Procedure DLay(Ticks : Word);
 Begin
  TimerCnt:=Ticks;
  Asm
   @RepLoop:
   Cmp TimerCnt,0
   Jg @RepLoop
  End;
 End;

Procedure DLaySec(Ticks : Word);
 Begin
  TimerCnt:=Round(Ticks*18.2);
  Asm
   @RepLoop:
   Cmp TimerCnt,0
   Jg @RepLoop
  End;
 End;

Procedure InstallInt1C;
 Begin
  GetIntVec($1C,@Int1CSave);
  SetIntVec($1C,Addr(TimerHandler));
 End;

Procedure RestoreInt1C;
 Begin
  SetIntVec($1C,@Int1CSave);
 End;

End. {You need to call InstallInt1C; to start it and make SURE you call
RestoreInt1C; before you exit your program.}


