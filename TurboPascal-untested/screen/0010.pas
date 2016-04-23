{ GLEN WILSON }

{$m 2000,0,0}  (* Stops Pascal using all of memory *)
{$R-,s-,v-,b-,n-,l+}  (* Nothing important, helps keep the size down*)
Program screensaver;  (* Only blanks screen on CGA/Mono not VGA/etc*)

Uses
  Dos, Crt;

Const
  TimerInt = $08;              {Timer Interrupt}
  KbdInt   = $09;              {Keyboard Interrupt}
  Timerlimit : Word = 5460;   {5 minute Delay}

Var
  Regs    : Registers;
  Cnt     : Word;
  PortNum : Word;
  PortOff : Word;
  Porton  : Word;
  OldKBDVEC   : Pointer;
  OldTimerVec : Pointer;
  i    : Real;
  code : Real;


Procedure STI;
Inline($FB);

Procedure CLI;
Inline($FA);

Procedure CallOldInt(Sub : Pointer);
(* Primitive way of calling Old Interrupt, never the less, you can see what is
   happening! *)
begin
Inline($9c/           { PushF }
       $FF/$5e/$06);  { Call DWord PTR [BP+6] }
end;

Procedure Keyboard(flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP : Word); Interrupt;

begin
  CallOldInt(OldKbdVec);
  if (CNT >= Timerlimit) then
    port[portnum] := porton;
  Cnt := 0;
  STI;
end;

Procedure Clock(flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP : Word); Interrupt;
begin
  CallOldInt(OldTimerVec);
  if (CNT > Timerlimit) then
    Port[portnum] := portoff
  else
    Inc(Cnt);
  STI;
end;


begin
 Regs.AH := $0F;
 INTR($10, regs); (* determine Type of video adapter (Mono or Cga) *)

  if Regs.AL= 7 then
  begin
    Portnum := $3b8;
    Portoff := $21;
    PortOn  := $2d;
  end
  else
  begin
    Portnum:=$3d8;
    Portoff:=$25;
    porton :=$2d;
  end;

  (* Save original Procedures *)
  GetIntVec(KbdInt, OldKbdVEc);
  GetIntVec(TimerInt, OldTimerVec);

  (* Install new Interrupts *)
  SetIntVec(timerint, @clock);
  SetIntVec(KbdInt, @Keyboard);

  Cnt := 0; (* Initialize counter *)
  Keep(0); (* Tell Pascal to keep us in memory *)
end.

{
it seems rather complex but most of that crap is For turning
on and off the screen.  if you don't have a CGA or MONO you can replace the
Port crap With Writeln statements so you can see whats hapening.

BTW This is an example from a Programming book ( can't remember what it is
called ) becareful, It might be covered by Copy right laws.
}
