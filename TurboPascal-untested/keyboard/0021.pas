{The problem is that the pause key actually paUses the Computer
via hardware.  to reset the pause, you can use the timer interrupt
to generate a reset process at every tick.  The method here
was taken from some Computer magazine.
}

Program TrapPause;
Uses Dos;
Var
  Timerint : Pointer;
  PauseFlag : Boolean;

Procedure PauseDetect(flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP: Word);
  {This latches on to the system timer interrupt to detect if the
   pause key has been pressed, and if so to reset the system to allow
   operation to continue and to set Pauseflag = True}
  interrupt;
  begin
    if memw[$0:$418] and 8 = 8 then  {Test bit 3}
    begin
      Pauseflag := True;
      memw[$0:$418] := memw[$0:$418] and $F7; {Set bit 3 = 0}
    end;
    Inline($9C/              {PushF}
           $3E/              {DS}
           $FF/$1E/timerint);{Far call to usual timer interrupt}
  end;


begin
  Getintvec($08,Timerint);      {Save old interrupt For timer}
  Setintvec($08,@PauseDetect);  {Redirect timer to PauseDetect}
end.

