(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0035.PAS
  Description: Simple Multi-Tasker
  Author: SEAN PALMER
  Date: 08-27-93  21:40
*)

{
 by Sean L. Palmer
 Public Domain

 This is a 'multitasking' Program in the sense that it hooks into
 the timer interrupt, but what that interrupt ends up actually
 doing is controlled by the current value in SaveAdr, which
 changes With each interrupt as the routine passes control back
 to the tick handler not by Exiting normally, but by an explicit
 transfer of control.
 The end result of this is that you can Write a state-driven
 interrupt handler
 The included example is RealLY simplistic, and barely tested.
 I intend to use this to Write a comm port driver that
 parses the incoming data as it receives it which would
 be nice in a communications Program that shells to Dos, as
 the incoming Chars could be saved to disk in the background
 With buffered ZModem or something...
}

Program intTest;

Uses
  Dos;

Var
  saveAdr : Word;  {offset in this code segment of where we are now}
  active  : Boolean;  {to avoid re-entrancy}

Procedure intHandler; Far; Assembler;
Asm
  pusha
  mov  ax, seg @DATA
  mov  ds, ax

  {anything you need to do before continuing (reading port data?), do here}

  in   al, $61  {click speaker as an example}
  xor  al, 2
  out  $61, al

  test active, $FF  {exit now if interrupted ourselves}
  jz   @OK
  popa
  iret

 @OK:
  inc Byte ptr active
  sti
  jmp [saveAdr]  {near jump to continue where handler last left off}
end;

{call this Procedure from StateHandler to suspend execution Until next time}

Procedure wait; near; Assembler;
Asm {wait For next interrupt}
  pop Word ptr saveAdr  {save where to continue next time}
  dec Byte ptr active
  popa                  {restore caller regs}
  iret
end;

Const
  c : Char = '.';

Procedure stateHandler;
begin
{
 a stateHandler Procedure should never ever Exit (only by calling 'wait'),
 shouldn't have any local Variables or parameters, and shouldn't call
 'wait' With anything on the stack (like from a subroutine).
 This routine is using the caller's (interrupted Program's) stack, so be
 very very careful}

 Asm
   pop bp  {clean up stack mess left by Turbo's Procedure header}
 end;
 {^ alternative method here is to init saveAdr to offset(proc)+3 and skip
  the push bp; mov bp,sp altogether}

  Repeat  {this is an example only}
    c := '@';
    wait;
    c := '.';
    wait;
  Until False;                {don't let it return normally!!}
end;

Var
  oldHook : Procedure;
  i       : Integer;

begin
  saveAdr := ofs(stateHandler);
  getIntVec($1C, @oldHook);
  setIntVec($1C, @intHandler);
  For i := 1 to 1500 do
    Write(c);
  setIntVec($1C, @oldHook);
end.



