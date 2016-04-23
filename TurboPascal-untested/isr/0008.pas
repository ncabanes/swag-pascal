 BC> I have the desire to create a Type of "watch dog" Procedure For a Program
 BC> I am writing. It has become increasingly attractive For me to create this
 BC> Procedure to activate at certain times every hour - i.e. at 15 past and 45
 BC> past the hour.

Perhaps if you insert this code into your Program. It works With the ISR 1C
called by the timerinterrupt 8 periodically. For testing reasons it calls the
batchFile at 15 and 45 seconds. Change finally the line "if(s=15) or (s=45)" to
"if (m=15) or (m=45)" to test the minutes.

Code written in TP6.0 :

{$M 16384,0,16384} (*Adjust to your requirements*)
Uses Dos,Crt;

Const
  WDTryTime = 18; (*18 ticks = about every second*)
  BatchFileName = 'woufwouf.bat'; (*BatchFile to start*) <<<your BatchFilename
Var
  WDCount : Integer;
  WDBusy,WdEvent : Boolean;
  WDSave1c,WDSaveExit: Pointer;
  DosReentrant : ^Byte;
  IntVec : Array[0..255] of Pointer Absolute 0:0;

Procedure STI;
Inline($FB);

Procedure CLI;
Inline($FA);

(*Do not use Turbo-Pascal I/O Routines in here.*)
(*Be also sure not to use GetTime/Date at the same time as this routine*)

Procedure WatchDog;interrupt;
Var h,m,s,c : Word;
begin
  if not WDBusy then
  begin
    WDBusy:=True;
    inc(WDCount);
    if DosReentrant^=0 then      (*No Dos op's in work ?*)
      if WDCount>=WdTryTime then (*Test only every second to prevent*)
      begin                      (*big loss in perFormance.        *)
        WDCount:=0;
        GetTime(h,m,s,c);              (*Get Time*)

here>>> if(s=15) or (s=45) then (*Call on 15 minutes and 45 minutes*)

        begin
          Cli;IntVec[$1c]:=WDSave1C;Sti;
          Port[$20]:=$a0;(*Report TimerInt finished to Interrupt-contr.*)
          Port[$20]:=$20;
          SwapVectors;      (*Execute COMMand.COM + batchFile*)
          Exec(GetEnv('COMSPEC'),'/C '+batchFilename);
          SwapVectors;
          Cli;IntVec[$1c]:=@Watchdog;Sti;
          WDEvent:=True;
        end;
      end;
    WDBusy:=False;
  end;
end;

Procedure WDRemove;
begin
  SetIntVec($1C,WDSave1c); (*Restore old 1c routine*)
  ExitProc:=WDSaveExit;
  Writeln('Exiting Watchdog');
  Halt(Exitcode);
end;

Procedure WDInstall;
Var Regs:Registers;
begin
  With Regs do
  begin
    ah:=$34;
    MsDos(regs);
    DosReentrant:=ptr(es,bx); (*Get Reentrant Pointer*);
  end;
  WdCount:=0;
  WDBusy:=False;
  WDEvent:=False;
  GetIntVec($1C,WDSave1C); (*Save old 1c routine*)
  SetIntVec($1C,@Watchdog); (*Assign Watchdog to int 1c*)
  WDSaveExit:=ExitProc;
  ExitProc:=@WDRemove;
  Writeln('Watchdog installed');
end;

Var c:Char;

begin
  WDInstall;
  Repeat (*Example Main Loop*)
    Write('Hello');
    if WDEvent then  (*Watch sign of Watchdog*)
    begin
      Writeln;Writeln('Event occured');
      WDEvent:=False;
    end;
    Delay(1000);
  Until KeyPressed;
  c:=ReadKey;
end.
