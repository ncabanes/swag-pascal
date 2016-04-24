(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0002.PAS
  Description: Display 
  Author: TREVOR J. CARLSEN
  Date: 05-28-93  14:09
*)

Unit Clock;
{
  Author:  Trevor J Carlsen 
  Purpose: Demonstrate a simple "on screen" clock.
  
  This demo Unit works by "hooking" the timer interrupt ($1c). This
  interrupt is called by the hardware interrupt ($08) approximately 18.2
  times every second and normally consists of a simple return instruction
  unless some other application has already hooked it.
  
  Because the routine is called roughly 18 times every second it is
  important that any processing it contains is optimised as much as
  possible.  Obviously the best way to do this is by assembly language but
  in this demo I have used almost pure Turbo Pascal and have set up a
  counter Variable and any processing is only done every 6 calls.  This is
  more than sufficient and minimises processing. The routine is by no
  means perfect - there will be a minor irregularity For the final 10
  seconds of each day and For about half a second each hour. Better this
  than to waste valuable processing time in the interrupt by coding it
  out.
  
  Because Dos is not re-entrant it is also important that the routine make
  no calls to any Procedure or Function that makes use of Dos For its
  operation. Thus no Writeln, Write can be used.  To display the time on
  screen an Array is addressed directly to screen memory.  Any changes in
  this Array are thus reflected on the screen.  The downside to this is
  that on older CGAs this would cause a "snow" effect and code would be
  needed to eliminate this. It also means that the TP Procedure GetTime
  cannot be used.  So the time is calculated from the value stored at the
  clock tick counter location.
  
  To display an on-screen clock all that is required is For a Programmer
  to include this Unit in the Uses declaration of the Program.}
  
Interface

Const
  DisplayClock : Boolean = True;

Implementation
{ Everything is private to this Unit }

Uses Dos;

Const
  line          = 0;  { Change as required For position of display on screen }
  column        = 72;                               { Top left corner is 0,0 }
  ScreenPos     = (line * 160) + (column * 2);
  Colour        = $1f;                                       { White on Blue }
  ZeroChar      = Colour shl 8 + ord('0'); 
  Colon         = Colour shl 8 + ord(':');
Type
  timestr       = Array[0..7] of Word;
  timeptr       = ^timestr;
Var
  time          : timeptr;
  OldInt1c      : Pointer;
  ExitSave      : Pointer;

{$F+}
 Procedure Int1cISR; interrupt;
  { This will be called every clock tick by hardware interrupt $08 }
  Const
    count       : Integer = 0;                  { To keep track of our calls }
  Var
    hr          : Word Absolute $40:$6e;
    ticks       : Word Absolute $40:$6c; 
                  { This location keeps the number of clock ticks since 00:00}
    min,
    sec         : Byte;
    seconds     : Word;
  begin
    Asm cli end;
    if DisplayClock then begin
      inc(count);
      if count = 6 then { ticks to update the display } begin
        count       := 0;  { equality check and assignment faster than mod 9 }
        seconds     := ticks * LongInt(10) div 182;       { speed = no Reals }
        min         := (seconds div 60) mod 60;
        sec         := seconds mod 60;

      { The following statements are what actually display the on-screen time}

        time^[0]    := ZeroChar + (hr div 10);         { first Char of hours }
        time^[1]    := ZeroChar + (hr mod 10);        { second Char of hours }
        time^[2]    := Colon;
        time^[3]    := ZeroChar + (min div 10);      { first Char of minutes }
        time^[4]    := ZeroChar + (min mod 10);     { second Char of minutes }
        time^[5]    := Colon;
        time^[6]    := ZeroChar + (sec div 10);      { first Char of seconds }
        time^[7]    := ZeroChar + (sec mod 10);     { second Char of seconds }
      end;  { if count = 6 }
    end;  { if DisplayClock }
    Asm         
      sti
      pushf                                  { push flags to set up For IRET }
      call OldInt1c;                              { Call old ISR entry point }
    end;
  end; { Int1cISR }

Procedure ClockExitProc;
  { This Procedure is VERY important as you have hooked the timer interrupt  }
  { and therefore if this is omitted when the Unit is terminated your        }
  { system will crash in an unpredictable and possibly damaging way.         }
  begin
    ExitProc := ExitSave;
    SetIntVec($1c,OldInt1c);               { This "unhooks" the timer vector }
  end;
{$F-}

Procedure Initialise;
  Var
    mode : Byte Absolute $40:$49;
  begin
    if mode = 7 then                                { must be a mono adaptor }
      time := ptr($b000,ScreenPos)
    else                                       { colour adaptor of some kind }
      time := ptr($b800,ScreenPos);      
    GetIntVec($1c,OldInt1c);              { Get old timer vector and save it }
    ExitSave := ExitProc;                          { Save old Exit Procedure }
    ExitProc := @ClockExitProc;                 { Setup a new Exit Procedure }
    SetIntVec($1c,@Int1cISR);   { Hook the timer vector to the new Procedure }
  end;  { Initialise }  
  
begin 
  Initialise;
end.


