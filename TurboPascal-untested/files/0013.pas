{
NORBERT IGL

> Anyone has got an idea on how to know if a drive is a real one or the
> result of a SUBST command Any help... welcome :-)

Well, DOS ( esp. COMMAND.COM ) has a undocumented Command
called TRUENAME, which takes wildcards also.
}

Program TrueName;

uses
  DOS;

function RealName(FakeName : String) : String;
Var
  Temp : String;
  Regs : Registers;
begin
  FakeName := FakeName + #0; { ASCIIZ }
  With Regs do
  begin
    AH := $60;
    DS := Seg(FakeName);
    SI := Ofs(FakeName[1]);
    ES := Seg(Temp);
    DI := OfS(Temp[1]);
    INTR($21, Regs);
    DOSERROR := AX * ((Flags And FCarry) shr 7);
    Temp[0] := #255;
    Temp[0] := CHAR(POS(#0, Temp) - 1);
  end;
  If DosError <> 0 then
    Temp := '';
  RealName := Temp;
end;

begin
  writeln(RealName(Paramstr(0)));
end.
