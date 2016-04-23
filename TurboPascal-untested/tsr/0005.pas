{  I'm sorry that my reply Sounded rude, it wasn't meant as such.  Probably
the best way to make a screen saver TSR is to latch onto inT $8, which is
called once a second to update the clock, using GetIntVec and SetIntVec.
Since your other TSR code is probably a normal Procedure For whatever other
interrupts you are using, just put the screen blanker Procedure inside the
other Procedure, and hopefully when you use Keep Dos will retain both your
normal TSR code and the screen saver code.
}
{$M 4096,0,0}
{$N-,S-}
Program TSRplusSaver;
Uses Dos;

Procedure MyTSR (Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP : Word);
inTERRUPT;
Const Maximum = 120; {2 minutes}
Var Elapsed : Word;
Var Saving  : Boolean;

Procedure ResetSvr (Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP : Word);
Interrupt;
begin
  if Saving then begin
     Saving := False;
     Port[984] := 41;      {Enable 6845 video}
     end;
  Elapsed := 0;
  end;

Procedure MyScreenSaver (Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP : Word);
Interrupt;
begin
  Inc (Elapsed);
  if Elapsed=Maximum then
     Port[984] := 33;      {Disable 6845 video}
     Saving := True;
     end;
  end;

begin {MyTSR}
  MemW[$b800:$0000] := 3585; {Happy face}
  end;

begin
   SetIntVec( $09, @ResetSvr);      {Reset screen saver on Keypress}
   SetIntVec( $08, @MyScreenSaver); {Increment elapsed every second,
                                     activate when ready}
   SetIntVec( $1C, @MyTSR);         {Set up your TSR code}
   Keep(0);
end.

{   I'm pretty sure something like this will work, but I haven't tried it
myself yet.  of course you'll have to add CLI instructions at the
beginning of each of the interrupt Procedure and a restore interrupts after
it, so nothing can occur during them except NMI.  You may have some trouble
there, since on the PCjr the NMI includes keyboard input (pretty stupid,
huh?)
}