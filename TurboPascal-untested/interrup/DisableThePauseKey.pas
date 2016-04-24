(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0015.PAS
  Description: Disable the pause key
  Author: GREG ESTABROOKS
  Date: 01-27-94  13:33
*)

{ Updated KEYBOARD.SWG on January 27, 1994 }

UNIT NoPause;                {  Unit to disable the pause key                }
                        {  Last Updated  Apr 26/93                      }
                        {  Copyright (C) Greg Estabrooks, 1993          }
INTERFACE
{***********************************************************************}
USES DOS;                       { IMPORT SetIntVec,GetIntVec.           }
VAR
     OldExit   :POINTER;        {  To hold pointer to old exit proc     }
     OldInt09  :POINTER;        {  To hold old int 9h handler           }

PROCEDURE ForgetPauses;
FUNCTION PausePressed :WORD;    { Returns number of times pause was     }
                                { Since last time ForgetPauses was called.}
{***********************************************************************}
IMPLEMENTATION
VAR
     NumPauses :WORD;           {  To hold number of times pause        }
                                {  was pressed. Not Directly accessible }
                                {  by other processes.                  }
PROCEDURE ForgetPauses; ASSEMBLER;
                       {  Routine to Clear Pause counter variable       }
ASM
  Mov NumPauses,0               {  Clear Pause Variable                 }
END;{ForgetPauses}

FUNCTION PausePressed :WORD; ASSEMBLER;
                      { Function to return number of times pause pressed}
ASM
  Mov AX,NumPauses              {  Load number of pauses into register  }
END;{PausePressed}

PROCEDURE TrapPause; ASSEMBLER;
ASM
  Push DS
  Push AX
  Push ES
  Mov AX,Seg @Data              {  Allow us to access numpauses.        }
  Mov DS,AX
  Mov AX,$40                    {  Point ES, to bios data area          }
  Mov ES,AX
  Mov AH,ES:[$18]               {  Put keyboard shift flags into AH     }
  And AH,8                      {  Clear all but potential pause flags  }
  Or AH,0                       {  Check for zero                       }
  Jz @NormalKey                 {  If it was zero pause wasn't pressed  }
  Add NumPauses,1               {  Add 1 to number of pauses pressed    }
  Mov AH,ES:[$18]               {  Load Flags again                     }
  And AH,$F7                    {  Clear pause flags                    }
  Mov ES:[$18],AH               {  Load new flags byte back into bios   }
@NormalKey:
  PushF                         {  Push flags onto stack                }
  Call [OldInt09]               {  Call old Int 9h handler              }
@Exit:
  Sti                           {  Allow Interrupts                     }
  Pop ES                        {  Restore registers that were used     }
  Pop AX
  Pop DS
  IRet                          {  Return from interrupt                }
END;{TrapPause}

{$F+}
PROCEDURE Restore_Pause;
                       {  Routine to restore int 9  and exit pointers   }
BEGIN
  SetIntVec(9,OldInt09);        { Restore Int pointer to old pointer    }
  ExitProc := OldExit;          { Restore Exit Pointer                  }
END;{Restore_Pause}
{$F-}

PROCEDURE InitTrap;
                   {  Routine to set Int pointers to TrapPause          }
BEGIN
  GetIntVec(9,OldInt09);        {  Get pointer to Old Int 9h            }
  SetIntVec(9,@TrapPause);      {  Point Int 9 to TrapPause             }
  OldExit := ExitProc;          {  Save Old Exit Pointer                }
  ExitProc := @Restore_Pause;   {  Set exit Pointer to new exit         }
END;{InitTrap}

BEGIN
  InitTrap;                        { Set up New Int 9h Handler             }
END.{***********************************************************************}
PROGRAM ShowNoPause;            { Demo of NoPause Unit. Greg Estabrooks.}
USES CRT,                       { IMPORT Clrscr,KeyPressed,ReadKey.     }
     NoPause;                   { Unit containing Pause routines.       }
VAR
   Misc :WORD;                  { Holds changing number to show the system}
                                { is not paused.                        }
BEGIN
  Clrscr;                       { Clear screen clutter.                 }
  ForgetPauses;                 { Clear the pauses number holder.       }
  Misc := 0;                    { Clear Counter.                        }
  REPEAT                        { Loop Until a key other than Pause is  }
                                { pressed.                              }
    GOTOXY(1,1);                { Always show info at top corner.       }
    Write(Misc:8,'...  You have pressed pause ',PausePressed:3,' times.');
    INC(Misc);                  { Increase counter to show a change.    }
  UNTIL KeyPressed;
END.{ShowNoPause};
{***********************************************************************}

