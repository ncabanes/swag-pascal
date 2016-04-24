(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0001.PAS
  Description: Millisecond Timer Unit
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:09
*)

{ millisecond timer Unit }

Unit msecs;

Interface

Var
   timer:Word;                     { msec timer }
   idle:Procedure; {  you can change this to do something useful when Delaying}

Procedure Delay_ticks(t:Word);     { resume Until t clock ticks have elapsed }
Procedure start_clock;             { starts the 1 msec timer }
Procedure stop_clock;              { stops the 1 msec timer }

Implementation

Uses Dos;

Procedure Delay_ticks(t:Word);
begin
  inc(t,timer);
  Repeat idle Until Integer(timer - t) >= 0;
end;

Const clock_active:Boolean = False;
      one_msec = 1193;
Var   save_clock:Pointer;
      clocks:Word;

Procedure tick_int; Far; Assembler;
Asm
  push ax
  push ds
  mov ax,seg @data
  mov ds,ax
  mov al,$20
  out $20,al
  inc [timer]
  add [clocks],one_msec
  jnc @1
  pushf
  call [save_clock]
@1:
  pop ds
  pop ax
  iret
end;


Procedure start_clock;
begin
  if clock_active then Exit;
  inc(clock_active);
  timer := 0;
  clocks := 0;
  getintvec($08,save_clock);
  setintvec($08,@tick_int);
  port[$43] := $36;
  port[$40] := lo(one_msec);
  port[$40] := hi(one_msec);
end;

Procedure stop_clock;
begin
  if not clock_active then Exit;
  dec(clock_active);
  port[$43] := $36;
  port[$40] := 0;
  port[$40] := 0;
  setintvec($08,save_clock);
end;

Procedure nothing; Far;
begin
end;

Var saveexit:Pointer;

Procedure uninstall; Far;
begin
  Exitproc := saveexit;
  if clock_active then stop_clock;
end;

begin
  timer := 0;
  idle := nothing;
  saveexit := Exitproc;
  Exitproc := @uninstall;
end.




