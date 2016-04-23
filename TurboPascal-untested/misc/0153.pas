{
From: ka9dgx@interaccess.com (Mike Warot)

  Here is the code I wrote to do cooperative multitasking in TP4, and have
since used in TP5, TP6, TP7. This version works with TP7, I make no
guarantees for earlier versions.
}

Unit Tasker;
{
  Non-Preemptive MultiTasking Unit
  for Turbo Pascal Version 4

  Author  : Michael Warot - Blue Star Systems
  Date    : November 1987
  Purpose : Simple multi-tasking for turbo pascal 4.0
  Version : 1.10

  V1.10  August    1988 MAW - After much modification, added LastP to
                              point to the highest numbered active process.
                              With MaxProc set to 30 and 2 tasks, took
                              effective yield time down from 240 uS to 38 uS
  V1.04  March     1988 MAW - Modify record used to save process, now
                              use a pointer instead of 2 words to save
                              the stack frame.
                              Eliminate redundant variable NextP
  V1.03  March,    1988 MAW - Modify code to save video state for a given
                              process. A flag Video_Save toggles this.
  V1.02  March,    1988 MAW - Modify code to support Sleep Function
                              Added procedures LOCK and UNLOCK to permit
                              use of non-reentrant procedures in programs
  V1.01  January,  1988 MAW - Remove obsolete startup function Init_Tasking.
                              Put in some documentation. Clean up code.
  V1.00  November, 1987 MAW - Initial version, simple and crude, but it works.
}
{$F+    Force FAR calls - must be on}
Interface
Uses
  Crt,Timer2;          { For saving screen status, etc }

Type
  FlagPtr    = ^Boolean;                 { Pointer to a flag           }
Var
  Save_Video : Boolean;                  { True for cursor saving }

Function Fork:Boolean; { Call this procedure to spawn a new process. The
                         procedure will return to your program twice. The
                         first time it will be the root process, and will
                         return a value of false, the second time it will
                         return a value of true }

Procedure Raw_Yield;


Procedure Yield;       { Call this procedure often in your code. This is the
                         heart of the Multi-Tasking, it will return after all
                         of the other processes have a crack at it.        }

Procedure Sleep(Flag : FlagPtr);
                       { Call this procedure with an address of a flag which
                         when TRUE, will re-awaken the process. Upon entry
                         this procedure will test the value of this flag, and
                         if FALSE, will mark the process HIBER.
                         This procedure makes a call to YIELD in all cases.
                         Note : Don't let all of you processes Sleep, or
                         you could put things into a deadlock. }

Procedure Lock(Resource : Byte);
                       { This procedure allows the programmer to insure that
                         a procedure is not entered twice, it does this by
                         having the second call yield until the resource is
                         free, using Sleep }

Procedure UnLock(Resource : Byte);
                       { This procedure unlocks a resource, allowing it to be
                         used by other processes }

Procedure KillProc;    { This procedure is intended to be called by a process
                         that has done all of it's work. It marks the process
                         as one that is 'DEAD' and thus never re-awakens }

Function  Child_Process:Boolean;
                       { This function returns True if the calling procedure
                         is a child process. This test should be used to branch
                         into a specific procedure for a given task.       }

Procedure SetPriority(P : Integer);

Function  ProcessCount:Integer;

Procedure Wait(TicksToWait : Longint);
                       { This procedure causes a task to wait by calling
                         yield until DT(timer2 unit) deterimes that
                         TicksToWait timer ticks have elapsed }

Implementation
{
  Hide this from the users....

  These procedures work on the following basis:
    1> For each process, there is an amount of memory reserved for
       a machine stack, this is called a Stack Frame. This holds
       the current state of a given process.

    2> The process table (Procs) contains pointers to all of the
       Stack Frames. When a task is to be swapped out, it's state
       is saved in it's own stack, then the frame pointer is placed
       in (Procs) until the process is to be swapped back in.

    3> Every one in a while, when a task has some time to share,
       it makes a call to Yield, which does all of the swapping.
}
Const
  MaxProc   = 100;           { Maximum number of processes
                               Adjust for your purposes..  }

Type
  ProcState = (Dead,
               Kill,
               Live,
               Slow,                    { Running, but in background }
               Pause,                   { Waiting for above          }
               Hiber);                  { What is the process doing?  }

  Task_Rec  = Record
                Frame     : Pointer;     { Frame save area}
                ID        : Word;        { Process Number }
                FrameBlk  : Pointer;     { Frame block }
                FrameSiz  : Word;        { Amount of memory user  }
                State     : ProcState;   { Is it a live process ? }
                HiberPtr  : FlagPtr;     { Pointer to "WAKE" flag }
                Priority  : LongInt;     { priority (0=Real Time) }
                NextTime  : Longint;     { Next wake up call @    }
              End; { Record }
Var
  MaxStack  : Word;

  SFrame    : Pointer;

  Procs     : Array[0..MaxProc] of Task_Rec; { Keeps the process pointers }
  NextP,                              { Last live process number  }
  ThisP,                              { Current process           }
  LastP     : Word;                   { Last Process number       }

  LiveCount : Word;                   { How many thing happening? }

  Locks     : Array[0..255] of Boolean; { Resource locks }

  Function  Ticks:Longint;
  Begin
    Inline($FA);                { CLI - Interupts off }
    Ticks := MemL[$0040:$006c];
    Inline($FB);                { STI - back on again }
  End; { Ticks }

{
  Here are the inline macros to handle the frame pointers for a task swap
}
  Procedure SaveFrame;
    Inline( $89/$2E/SFrame        {   MOV     [0000],BP     }
           /$8C/$16/SFrame+2      {   MOV     [0002],SS     } );

  Procedure LoadFrame;
    Inline( $8B/$2E/SFrame        {   MOV     BP,[0000]     }
           /$8E/$16/SFrame+2      {   MOV     SS,[0002]     } );

Function Fork:Boolean;                { Create a new process      }
Var
  Tmp : Boolean;
Begin
  SaveFrame;                          { Save current frame pointer }
  Tmp := True;                        { Assume child process }
  NextP := 0;                         { Search the process table for an }
  While (NextP <= MaxProc) AND        { open entry for the new process  }
        (Procs[NextP].State <> Dead) do
          Inc(NextP);

  If (NextP <= MaxProc) then          { If table not full, then }
  begin
    If NextP > LastP then             { If We past it, bump it }
      LastP := NextP;

    With Procs[NextP] do
    begin
      FrameSiz := MaxStack;           { Set up size of area }
      GetMem(FrameBlk,FrameSiz);
      State     := Live;              { Note we're ready to go.... }
      ID        := NextP;             { Set up the new task       }
      Frame     :=
        Ptr(Seg(FrameBlk^),Ofs(SFrame^) ); { Setup stack    }

      Priority  := 0;

      Move(Mem[Seg(SFrame^)   : Ofs(SFrame^)-2],
           Mem[Seg(FrameBlk^) : Ofs(SFrame^)-2],
           (MaxStack+2)-Ofs(SFrame^) );
    end;
    Inc(LiveCount);                   { Bump process counter }
    Tmp := False;
  end; { we can fork }
  LoadFrame;
  Fork := Tmp;
End; { Raw_Fork }

Procedure Raw_Yield;                  { Let the other task's go at it }
Begin
  SaveFrame;                          { Save our current stack frame  }
  Procs[ThisP].Frame := SFrame;       { in our entry in Procs         }

  If Procs[ThisP].State = Slow then
  With Procs[ThisP] do
  begin
    State := Pause;
    NextTime := Ticks+Priority;
    If NextTime > $001800ae then
      NextTime := NextTime - $001800ae;
  End; { with }

  If LiveCount >= 1 then              { If we actually have a task to }
  begin                               { swap to, then....             }
    repeat                            { keep looking until we hit a   }
      If ThisP < LastP then           { live one                      }
        Inc(ThisP)
      else
        ThisP := 0;

      With Procs[ThisP] do
      Case State of
        Dead,
        Live    : ;

        Hiber   : If HiberPtr^ then   { Check to see if we should }
                    State := Live;    { wake a sleeping process   }
        Pause   : If (Priority = 0) OR
                     (Ticks > NextTime) then
                  begin
                    State    := Slow;                   { handle slow task }
                  end;
        Kill    : If ThisP <> 0 then                    { Kill Off a process }
                  Begin
                    FreeMem(FrameBlk,FrameSiz);
                    State := Dead;
                  end;
      End; { Case State }
    until (Procs[ThisP].State = Live) or
          (Procs[ThisP].State = Slow);
  end;

  SFrame := Procs[ThisP].Frame;        { Load new stack frame }
  LoadFrame;
End; { Raw_Yield }

Procedure Yield;
Var
  ox,oy  : byte;
  wmax,
  wmin   : word;
  attr   : byte;
Begin
  If Not Save_Video then     { Implemented this way in case the value changes }
    Raw_Yield
  else
  begin
    attr := TextAttr;                         { Save current colors  }
    ox   := WhereX;         oy := WhereY;     { save cursor position }
    wmin := WindMin;      wmax := WindMax;    { save window size     }

    Raw_Yield;    { actual Yield Call }

    WindMin := wmin;      WindMax := wmax;    { restore window size  }
    GotoXY(ox,oy);                            { restore cursor       }
    TextAttr := attr;                         { restore colors       }
  end;
End; { Yield_Plus }

Procedure Sleep(Flag : FlagPtr);     { Put a process to sleep           }
Begin
  If NOT Flag^ Then
  Begin
    Procs[ThisP].HiberPtr := Flag;   { Set wake up pointer }
    Procs[ThisP].State    := Hiber;  { Mark this process as hibernating }
  End;
  Yield;                             { Do a yield, either way, to keep
                                       things going smoothly            }
End; { Sleep }

Procedure Lock(Resource : Byte);     { Lock a resource ID }
Begin
  If NOT Locks[Resource] Then        { If not open, then wait until }
    Sleep(@Locks[Resource]);         { the resource becomes available }

  { Resource MUST be available now! }

  Locks[Resource] := FALSE;          { Make it unavailable for use  }
End; { Lock }

Procedure UnLock(Resource : Byte);   { Unlock that resource }
Begin
  Locks[Resource] := True;           { Make the resource available }
End; { UnLock }

Procedure KillProc;                  { Stop a process in it's tracks    }
Begin
  If LiveCount > 1 then              { if we are actually swapping then }
  begin
    Procs[ThisP].State := Kill;      {   mark us as dead                }
    Dec(LiveCount);                  {   Bump process count             }
    Raw_Yield;                       {   and yield. (Never returns)     }
{$IFDEF DEBUG}
    WriteLn('IN TASKER.PAS - FATAL ERROR, PROCESS EXCEPTION');
{$ENDIF}
  end
  else                               { if not swapping, then            }
    Halt(0);                         { exit to dos.....                 }
End; { KillProc }

Function Child_Process;              { Returns true if not root process }
Begin
  Child_Process := ThisP <> 0;
End;

Procedure SetPriority;               { Set number of clicks between runs }
Begin
  With Procs[ThisP] do
  begin
    Priority := P;
    If P = 0 then
      State  := Live
    else
      State  := Slow;
  end;
End;

Function ProcessCount;
Begin
  ProcessCount := LiveCount;
End;

  Procedure Wait(TicksToWait : Longint);
  var
    t : longint;
  begin
    If TicksToWait <= 0 then EXIT;
    StartTime(T);
    While DT(T) < TicksToWait do Yield;
  end;

{ Initialization code, called automatically by the user program,
  like it or not!                                                      }
Procedure InitTasking;
Var
  i : byte;
Begin
  NextP := 0;                        { We are in the root process      }
  ThisP := 0;
  LastP := 1;                        { Last Active process             }
  FillChar(Procs,SizeOf(Procs),#0);
  Procs[0].State := Live;
  LiveCount := 1;                    { And one task is running (this one) }
  For i := 0 to 255 do
    Locks[i] := True;                { All resources available }
  Save_Video := True;
End;

Begin
  MaxStack := Sptr+4;
  InitTasking;
End.

