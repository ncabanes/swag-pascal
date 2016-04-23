{ GREG ESTABROOKS }

Program Win3XInf;      { Simple Detection routines For Windows 3.X    }
                       { Last Updated March 3/93, Greg Estabrooks     }
Uses
  Crt,
  Dos;

Var
  Regs : Registers;    { to hold register info }

Function Win3X : Boolean;
{ Routine to determine if Windows is currently running }
begin
  Regs.AX := $4680;    { Win 3.x Standard check }
  Intr($2F, Regs);     { Call Int 2F }
  if Regs.AX <> 0 then { if AX = 0 Win in Real mode }
  begin                { else check For enhanced mode }
    Regs.AX := $1600;  { Win 3.x Enhanced check }
    Intr($2F, Regs);   { Call Int 2F }
    if Regs.AL in [$00,$80,$01,$FF] then { Check returned value }
      Win3X := False   { Nope not installed }
    else
      Win3X := True;   { Ya it is }
  end
  else
    Win3X := True;     { Return True }
end;


Function WinVer :Word;
{  Returns a Word containing the version of Win Running }
{  Should only be used after checking For Win installed }
{  Or value returned will be meaningless                }
begin
  Regs.AX := $1600;    {  Enhanced mode check }
  Intr($2F, Regs);     {  Call Int 2F         }
  WinVer := Regs.AX;   {  Return proper value }
end;


begin
  ClrScr;
  if Win3X then
  begin
    Writeln('Windows is Running! ');    { Display version }
    Writeln('Version Running is : ', Lo(WinVer), '.', Hi(WinVer));
  end
  else
    Writeln('Windows is not Running!');
end.
