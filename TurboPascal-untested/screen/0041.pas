{
KELLY SMALL

Ok here's a quick example of how you can control the screen
output during an Exec.  BAsically you hook Int $29 which is an
internal bios hook For screen output.  Any Character that would
go to the screen is intercepted by the Interrupt handler and then
TP's Write Procedure is used to output the Charcater to the
screen.  Please note that this will only work With the Crt Unit
and it's direct screen Write methods, not output via the Dos
device..  Of course I assume you are using the Crt Unit since you
are also using the Window Procedure.  if the Program you exec
Uses direct screen Writes then this routine will not work.
}

Program WinHold;
{$M 8096,0,0}
Uses
  Crt, Dos;

Var
  OldIntVect : Pointer;

{F+}
Procedure Int29Handler(AX, BX, CX, DX, SI, DI, DS, ES, BP : Word); Interrupt;
Var
  Dummy : Byte;
begin
  Asm
    Sti
  end;
  Write(Char(Lo(Ax)));
  Asm
    Cli
  end;
end;
{$F-}

begin
  ClrScr;
  Writeln('this line better stay put');
  Window(10, 15, 60, 25);
  GetIntVec($29, OldIntVect);            { Save the old vector }
  SetIntVec($29, @Int29Handler);         { Install interrupt handler }
  SwapVectors;
  Exec(GetEnv('COMSPEC'),'/c dir /p');
  SwapVectors;
  SetIntVec($29, OldIntVect);            { Restore the interrupt }
  Window(1, 1, 80, 25);
  GotoXY(1, 2);
  Writeln('2nd line I hope');
  ReadLn;
end.

