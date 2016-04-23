Uses Dos;
var
     ExitSave,
     BKDISave,
     BKDIHandler       : Pointer;
     Regs              : Registers;
     Abort             : Boolean;

{$F+}
procedure NewCntlBreakHandler(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:Word);
interrupt;
begin
inline($FA);  { disable interrupts }
              { do nada widda data }      { OR DO ANYTHING YOU WANT }
inline($FB);  { enable interrupts }
Abort := True;         { Use this for (while NOT abort do..) }
end;

procedure NewBKDIHandler(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:Word);
interrupt;
begin
inline($FA);  { disable interrupts }
              { do nada widda data }      { OR DO ANYTHING YOU WANT }
inline($FB);  { enable interrupts }
AX := 0;      {This must remain. An oversight in Turbo Pascal.}
end;

procedure MyExit;
begin
     ExitProc := ExitSave;
     SetIntVec($1B, BKDISave);
     SetIntVec($24, BKDIHandler);
end;
{$F-}


begin
     ExitSave := ExitProc;
     ExitProc := @MyExit;
     Regs.AH := $35;    { Get Cntl-Break Interrupt Vector }
     Regs.AL := $1B;
     Intr($21,Regs);
     BKDISave := Ptr(Regs.ES, Regs.BX);
     SetIntVec($1B, @NewBKDIHandler);
     Regs.AH := $35;    { Get Cntl-Break Handler Interrupt Vector }
     Regs.AL := $23;
     Intr($21,Regs);
     BKDIHandler := Ptr(Regs.ES, Regs.BX);
     SetIntVec($23, @NewCntlBreakHandler);

     { Do whatever here. When finished, the old interrupt vectors are
       restored in the MyExit procedure }
end.

