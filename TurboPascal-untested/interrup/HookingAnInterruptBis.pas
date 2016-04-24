(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0012.PAS
  Description: Hooking an Interrupt
  Author: CHRIS LAUTENBACH
  Date: 11-02-93  05:56
*)

{
CHRIS LAUTENBACH

║ I understand basically what you're saying - have a TSR/ISR define
║ Variables Within itself, then have any child processes hook into those
║ Variables via an interupt inquiry. However, I'm still a bit fuzzy on it.
║ Could you provide an example, or a better definition?

    Here's an example of how to hook an interrupt....
}

Unit ExampleInt;  { Interrupt hooker example }

{ Written 08/15/93 by Chris Lautenbach.  Released to the public domain.     }

{ This Unit, when placed in the Uses clause of your main Program, will hook }
{ Dos Interrupt 28h (Dos Idle) which is called by Dos when it isn't busy.   }
{ Under normal circumstances, this will produce a sort of 'multitasking'    }
{ effect when Dos calls it.  Make sure you call the NotBusy Procedure in    }
{ any keyboard wait loops -- or any other loop that continues For a While,  }
{ otherwise Dos will not get a chance to service Int 28h.                   }

{ In addition to hooking Int28h, it also provides a custom Exit Procedure   }
{ to deactivate the interrupt.  In this manner, this Unit can be totally    }
{ transparent to the Program it is included in -- even if the Program       }
{ terminates With an error, the interrupt is always disconnected.           }

{ Access to IntStart and IntStop are provided thru the Interface section to }
{ allow disabling of the interrupt -- in Case a Dos shell or similar        }
{ operation is required.                                                    }

Interface

Uses
  Dos, Crt;

Procedure IntStart;                         { Hook interrupt 28h - internal }
Procedure IntStop;                        { Unhook interrupt 28h - internal }
Procedure NotBusy; Inline($CD/$28);           { Call the Dos Idle interrupt }

Var
  Int28Orig,
  OldExitProc : Pointer;

Implementation

Procedure JmpOldISR(OldISR : Pointer);                 { Jump to an old ISR }
Inline ($5B/$58/$87/$5E/$0E/$87/$46/$10/$89/
        $EC/$5D/$07/$1F/$5F/$5E/$5A/$59/$CB);

{$F+}
Procedure Int28Handler(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:Word);interrupt;
begin
  Inline($FA);                                        { Turn interrupts off }

  { ... your code goes here ... }

  Inline($FB);                                    { Turn interrupts back on }
  JmpOldIsr(Int28Orig);            { Jump to the original interrupt address }
end;
{$F-}

Procedure IntStart;
begin
  GetIntVec($28, Int28Orig);                  { Save original Int 28 vector }
  SetIntVec($28, @Int28Handler);       { Install our cool new Int 28 vector }
end;

{$F+}
Procedure IntStop;
begin
  SetIntVec($28, Int28Orig);                       { Restore Int 28 handler }
end;

Procedure IntExit;
begin
  ExitProc := OldExitProc;                     { Restore old Exit Procedure }
  IntStop;                                       { Deactivate our interrupt }
end;
{$F-}

begin
  OldExitProc := ExitProc;                     { Save the current Exit proc }
  ExitProc := @IntExit;                         { Install our new Exit proc }
  IntStart;                                      { Initialize our interrupt }
end.


