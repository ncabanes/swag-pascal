{
REYNIR STEFANSSON

Some time ago I looked at the Waffle BBS v1.63. I wrote this proglet
to create a DOORINFO File For certain aftermarket utilities. Here you are:
}

Program DIMaker; {Writes DOORINFO.DEF/DORINFOn.DEF For Waffle BBS. }

Var
  tf          : Text;
  Graphic     : Integer;
  Port        : Char;
  SysName,
  SysOpFirst,
  SysOpLast,
  Baud,
  Terminal,
  First,
  Last,
  CallLoc,
  TimeLeft,
  SecLev,
  FossilOn,
  SysDir,
  FileName    : String;

{ Command line For Waffle: }

{ dimaker ~%b ~%t ~%O ~%a ~%F ~%A@~%n ~%L -1 [-|n] }

Procedure WriteDorInfo;
begin
  Assign(tf, SysDir+FileName+'.DEF');
  ReWrite(tf);
  WriteLn(tf, SysName);                { BBS name }
  WriteLn(tf, SysOpFirst);             { SysOp's first name }
  WriteLn(tf, SysOpLast);              { SysOp's last name }
  WriteLn(tf, 'COM', Port);            { COMport in use }
  WriteLn(tf, Baud, ' BAUD,8,N,1');    { Speed and Char format }
  WriteLn(tf, '0');                    { ? }
  WriteLn(tf, First);                  { User's first name }
  WriteLn(tf, Last);                   { User's last name }
  WriteLn(tf, CallLoc);                { User's location }
  WriteLn(tf, Graphic);                { 1 if ANSI, 0 if not. }
  WriteLn(tf, SecLev);                 { Security level }
  WriteLn(tf, TimeLeft);               { Time Until kick-out }
  WriteLn(tf, FossilOn);               { -1 if using FOSSIL, 0 if not }
  Close(tf);
end;

{ Don't let my reusing of Variables disturb you. }
Procedure GatherInfo;
begin
  FileName[1] := '-';
  SysName := ParamStr(0);
  Graphic := Length(SysName);
  Repeat
    Dec(Graphic)
  Until SysName[Graphic]='\';
  SysDir := Copy(SysName, 1, Graphic);
  Assign(tf, Copy(SysName, 1, Length(SysName)-4)+'.CFG');
  Reset(tf);
  ReadLn(tf, SysName);
  ReadLn(tf, SysOpFirst);
  ReadLn(tf, SysOpLast);
  Close(tf);
  Baud     := ParamStr(1);
  Terminal := ParamStr(2);
  TimeLeft := ParamStr(3);
  SecLev   := ParamStr(4);
  First    := ParamStr(5);
  Last     := ParamStr(6);
  CallLoc  := ParamStr(7);
  FossilOn := ParamStr(8);
  FileName := ParamStr(9);
  Port := FileName[1];
  if Port = '-' then
    FileName := 'DOORINFO'
  else
    FileName := 'DORINFO'+Port;
  if Terminal='vt100' then
    Graphic := 1
  else
    Graphic := 0;
  Port := '2';
  if Baud='LOCAL' then
  begin
    Baud := '0';
    Port := '0';
  end;
end;

begin;
  GatherInfo;
  WriteDorInfo;
end.
