{
I am looking For something like in BASIC where you could ON ERRO GOSUB
and anytime there was an error the Program re-routed..

It Sounds like you're after two things; a method of checking your Printer
and a means of trapping runtime errors.
}
Function PrinterReport:Byte;
{ This Function requires the Dos Unit. Returned values mean the following -
  0 = Printer is okay
  1 = Printer is out of paper
  2 = Printer is offline
  3 = Printer is busy
  4 = God knows what's wrong With the Printer but I'd get an engineer out.}
Var
  Regs : Registers;
begin
  With Regs do
  begin
    Ah := 2;
    Dx := LPTport;
    intr($17,Regs);
    if (Ah and $B8) = $90 then PrinterReport := 0
    else if (Ah and $20) = $20 then PrinterReport := 1
    else if (Ah and $10) = $00 then PrinterReport := 2
    else if (Ah and $80) = $00 then PrinterReport := 3
    else if (Ah and $08) = $08 then PrinterReport := 4;
    end;
end; { of Function }

{
As For trapping runtime errors, all you have to do is replace the
standard Exit Procedure With your own. For example...
}

Program JohnMajorGoosedTheCook;
Var
  SavedExitPoint : Pointer; { This holds the old Exit proc value }
  Number         : Integer;

{$F+}
Procedure MyExitProc;
{$F-}
begin
  if errorAddr <> NIL then { if you got a runtime error... }
  begin
    Writeln ('The Programmer got it wrong again. There has been an');
    Writeln ('error at ',seg(errorAddr^), ':', ofs(errorAddr^));
    Writeln ('with an Exit code of ',exitCode);
    Writeln ('Please call him on 123-4567 and give him dogs abuse.');
    errorAddr := NIL; { which cancels the runtime error address...}
    ExitCode := 0;    { which cancels the runtime error code }
  end;
  Exitproc := SavedExitPoint; { restore the old Exit Procedure...}
end; { of Procedure }

begin
  SavedExitPoint := ExitProc;  { Save the old Exit Procedure...  }
  ExitProc := @MyExitProc;     { ...and replace it With your own }
  Number := 0;                 { Uh oh... }
  Writeln (4 div Number);      { Oh dear...}
end. { of PROGRAM }
