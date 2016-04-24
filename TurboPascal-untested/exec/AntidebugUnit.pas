(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0043.PAS
  Description: Anti-Debug unit
  Author: BRAD ZAVITSKY
  Date: 05-31-96  09:16
*)

Here is an anti-debugging unit I created.  Use AntiOn at the start of
whatever has to be hidden (Password/Key gen) and AntiOff at the end.

Actions:
1) Disable Keyboard
2) Change interrupts 1&3 {Trace and Breakpoint}
3) Loop until system time changes. {This will mess up Turbo Debugger}

Note:
Interrupts are accessed directly instead of through DOS function 25h,
this will prevent a debugger that takes over all the interrupts from
disabling from still being able to trace/add breakpoints.

Right now, intxx is set to INT$20 (Halt program) which will crash the
debugger.  Set it's offset to $10 (INT$04) to just ignore the commands.


{$A+,B-,D-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}

unit AntiDbug;

interface

{Enable anti-debugging technique's, Keyboard will no longer work}
procedure AntiOn;
{Disable anti-debugging technique's}
procedure AntiOff;
{Halts some debuggers (Turbo Debugger), called at unit init;
 Can be called freely}
procedure HaltDebug;

implementation

var
  {Direct interrupt access}
  Int01: Pointer absolute $0:$004;
  Int03: Pointer absolute $0:$00C;
  IntXX: Pointer absolute $0:$080; {New interrupt, 04=$10, 20=$80}


  {Saved interrupts}
  SaveInt01,
  SaveInt03: Pointer;

procedure Cli; inline($FA); {Clear interrupts}
procedure Sti; inline($FB); {Store interrupts?}

procedure HaltDebug; assembler;
asm
  {Wait until clock timer changes}
  push ds
  xor ax, ax
  mov ds, ax
  mov ah, [046Ch]
@@TimerWait:
  mov al, [046Ch]
  cmp al, ah
  je @@TimerWait
  pop ds
end;

procedure AntiOn;
begin
  Port[$21] := Port[$21] or $02;
  {Disable interrupts}
  Cli;
  Int03 := IntXX;
  Int01 := IntXX;
  Sti;
end;

procedure AntiOff;
begin
  Port[$21] := Port[$21] and $fd;
  {Enable interrupts}
  Cli;
  Int01 := SaveInt01;
  Int03 := SaveInt03;
  Sti;
end;

begin
  {Try to mess up debuggers}
  HaltDebug;
  {Save interrutps}
  SaveInt01 := Int01;
  SaveInt03 := Int03;
end.

