{
From: JAKE CHAPPLE
Subj: Events on IRQ/TIMERS
---------------------------------------------------------------------------
}

{----------------------- Beginning of TIMER.PAS -----------------------}
Unit Timer;

{========================================================================}
{                           INTERFACE SECTION                            }
{========================================================================}
{                                                                        }
{ This unit implements a set of general purpose, low resolution timers   }
{ for use in any application that requires them.  The design of the      }
{ timer system is adapted from the following magazine article:           }
{                                                                        }
{   Jones S., A High-Performance Lightweight Timer Package, Tech         }
{      Specialist, Vol. 2, No. 1, Jan 1991, pp 17-27.                    }
{                                                                        }
{ Most of Jones' design has been copied, although this implementation is }
{ in Turbo Pascal rather than MASM.  By default, this unit provides 10   }
{ timers, although this can be increased by increasing the value of      }
{ MAX_TIMER and re-compiling.                                            }
{                                                                        }
{ Timers are referenced by "handles" i.e. small integers.  These are     }
{ actually indexes into the timer array.  To obtain a handle one must    }
{ ALLOCATE a timer.  The Allocate function also requires the address of  }
{ a routine to execute when the timer expires as well as a user context  }
{ variable.  The timer function must be compiled as a FAR routine.  The  }
{ user context variable is a 16 bit word of data that can be used for any}
{ application specific purpose.  It is passed to the timer routine when  }
{ the timer expires.  This is useful if a common timer routine is used   }
{ for multiple timers.  It allows the common timer routine to determine  }
{ which timer expired and take appropriate action.                       }
{                                                                        }
{ Once a timer is allocated, it must be STARTED.  The StartTimer         }
{ procedure requires the timer handle and a timer running time.  The     }
{ timer running timer is passed as a RELATIVE number of MILLISECONDS i.e.}
{ the number of milliseconds from now when the timer should expire.      }
{                                                                        }
{ A timer can be stopped before it expires with StopTimer which just     }
{ requires the timer handle.  There is the possibility that the StopTimer}
{ routine could be interrupted by a clock tick and the expiration routine}
{ could run before the StopTimer procedure actually stops the timer.     }
{ It's up to you to guard against this.                                  }
{                                                                        }
{ Finally, an allocated timer can be deallocated with DeallocateTimer    }
{========================================================================}

INTERFACE

uses
    Dos;

type
    UserProc = procedure(context : word);


function  AllocateTimer(UserContext : word; UserRtn : UserProc) : integer;
procedure StartTimer(handle : integer; rel_timeout : longint);
procedure StopTimer(handle : integer);
procedure DeallocateTimer(handle : integer);

{========================================================================}
{                        IMPLEMENTATION SECTION                          }
{========================================================================}

IMPLEMENTATION

const
     MAX_TIMER = 10;            {Total number of timers}
     MILLISECS_PER_TICK = 55;   {clock tick interval}
     TIMER_ALLOCATED = 1;       {bits in the timer flags word}
     TIMER_RUNNING   = 2;

type
    timer_rec = record                  {Timer descriptor record}
                  timeout : longint;    {Timeout.  Absolute number of millisecs}
                                        {From beginning of program execution}
                  routine : UserProc;   {User procedure to run on expiration}
                  flags   : word;       {Timer status flags}
                  context : word;       {User parameter to pass to User Proc}
                end;
var
   timers      : array[1..MAX_TIMER] of timer_rec;   {timer database}
   Int1CSave   : pointer;  {dword to hold original Int $1C vector}
   TimeCounter : longint;  {incremented by 55 millisecs on every entry to ISR}
   ExitSave    : pointer;  {Save the address of next unit exit proc in chain}
   i           : integer;  {loop counter}

{$F+}
{------------------------------------------------------------------------}
procedure Clock_ISR; interrupt;
{------------------------------------------------------------------------}
{ Description:                                                           }
{   This is an interrupt service routine which is hooked into the PC's   }
{   $1C vector.  An Int $1C is generated at each clock tick.  Int $1C is }
{   executed by the hardware interrupt service routine after it has up-  }
{   dated the system time-of-day clock.                                  }
{ Parameters:                                                            }
{   None.                                                                }
{------------------------------------------------------------------------}
var
   i : integer;        {local loop counter}
begin

  {Update the current time, relative to the start of the program}

  inline($FA); {cli}
  TimeCounter := TimeCounter + MILLISECS_PER_TICK; {update millisecond counter}

  {Scan the array of timers looking for ones which have expired}

  for i := 1 to MAX_TIMER do
    with timers[i] do
      if (flags and TIMER_ALLOCATED) > 0 then   {Is this timer allocated? if no}
        if (flags and TIMER_RUNNING) > 0 then   {Is this timer running? if not}
          if timeout <= TimeCounter then begin  {Has this timer expired yet?}
            flags := flags and (not TIMER_RUNNING); {turn off running flag}
            inline($FB);          {sti}
            routine(context);     {call user expiration routine}
            inline($FA);          {cli}
          end;
  inline($FB); {sti}
end;
{$F-}

{------------------------------------------------------------------------}
function AllocateTimer(UserContext : word; UserRtn : UserProc) : integer;
{------------------------------------------------------------------------}
{ Description:                                                           }
{   Allocate the next available timer in the timer database for use by   }
{   application.                                                         }
{ Parameters:                                                            }
{   UserContext - application specific word of data to be passed to the  }
{                 expiration routine when it is called.                  }
{   UserProc - address of a procedure to be called when the timer expires}
{ Returns:                                                               }
{   Handle - integer from 1 to MAX_TIMER                                 }
{            OR -1 if no timers available.                               }
{------------------------------------------------------------------------}
var
   i : integer;
begin
  inline($FA); {cli}
  for i := 1 to MAX_TIMER do begin  {scan timer database looking for 1st free}
    with timers[i] do begin
      if flags = 0 then begin
         flags := TIMER_ALLOCATED;      {Mark timer as allocated}
         context := UserContext;        {Save users context variable}
         routine := UserRtn;            {Store user routine}
         AllocateTimer := i;            {Return handle to timer}
         inline($FB);                   {Enable interrupts}
         exit;
      end;
    end;
  end;
  { No timers available, return error}
  AllocateTimer := -1;
  inline($FB);
end;

{------------------------------------------------------------------------}
procedure DeallocateTimer(handle : integer);
{------------------------------------------------------------------------}
{ Description:                                                           }
{   Return a previously allocated timer to the pool of available timers  }
{------------------------------------------------------------------------}
begin
  timers[handle].flags := 0;
end;


{------------------------------------------------------------------------}
procedure StartTimer(handle : integer; rel_timeout : longint);
{------------------------------------------------------------------------}
{ Description:                                                           }
{    Start an allocated timer ticking.                                   }
{ Parameters:                                                            }
{    Handle - the handle of a previously allocated timer.                }
{    rel_timeout - number of milliseconds before the timer is to expire. }
{------------------------------------------------------------------------}
begin
  inline($FA);  {cli}
  with timers[handle] do begin
    flags := flags or TIMER_RUNNING;       {set timmer running flag}
    timeout := TimeCounter + rel_timeout;  {Convert relative timeout to absolute}
  end;
  inline($FB);  {sti}
end;

{------------------------------------------------------------------------}
procedure StopTimer(handle : integer);
{------------------------------------------------------------------------}
{ Description:                                                           }
{   Stop a ticking timer from running.  This routine does not deallocate }
{   the timer, just stops it.  Remember, it is possible for the clock    }
{   interrupt to interrupt this routine before it actually stops the     }
{   timer.  Therefore, it is possible for the expiration routine to run  }
{   before the timer is stopped i.e. unexpectedly.                       }
{ Parameters:                                                            }
{   Handle - handle of timer to stop.                                    }
{------------------------------------------------------------------------}
begin
  with timers[handle] do
     flags := flags and (not TIMER_RUNNING);
end;

{$F+}
{------------------------------------------------------------------------}
Procedure myExitProc;
{------------------------------------------------------------------------}
{ Description:                                                           }
{  This is the unit exit procedure which is called as part of a chain of }
{  exit procedures at program termination.                               }
{------------------------------------------------------------------------}
begin
  ExitProc := ExitSave;  {Restore the chain so other units get a turn}
  SetIntVec($1C, Int1CSave);     {restore the original Int $1C vector}
end;
{$F-}

{=========================================================================}
{                        INITIALIZATION SECTION                           }
{=========================================================================}

Begin {unit initialization code}

  (* Establish the unit exit procedure *)

  ExitSave := ExitProc;
  ExitProc := @myExitProc;

  {Initialize the timers database and install the custom Clock ISR}

  for i := 1 to MAX_TIMER do   {clear flag word for all timers}
     timers[i].flags := 0;
  TimeCounter := 0;              {clear current time counter}
  GetIntVec($1C, Int1CSave);     {Save original Int $1C vector}
  SetIntVec($1C, @Clock_ISR);    {install the the clock ISR}
end.

{------------------------- End of TIMER.PAS -----------------------------}

{---------------------- Beginning of TIMERTST.PAS -----------------------}
program timer_test;

uses
    Crt, timer;
var
    t1, t2 : integer; {timer handles}
    done   : boolean;

{---- Procedure to be run when timer 1 expires ----}
procedure t1_proc(context1 : word); far;
begin
  writeln('Timer ',context1);
  StartTimer(t1, 1000);        {Keep timer 1 running}
end;

{---- Procedure to be run when timer 2 expires ----}
procedure t2_proc(context2 : word); far;
begin
  done := true;
  writeln('Timer ',context2,' expired');
end;

begin
  ClrScr;
  done := false;
  t1 := AllocateTimer(1, t1_proc);        {Create timer 1}
  t2 := AllocateTimer(2, t2_proc);        {Create timer 2}
  StartTimer(t2, 5000);        {Start timer 2 for 5 second delay}
  StartTimer(t1, 1000);        {Start timer 1 for 1 second delay}
  while not done do begin      {Do nothing until timer 2 expires}
     end;
  StopTimer(t1);
end.
