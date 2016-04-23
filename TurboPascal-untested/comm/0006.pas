{ determine if ANSI.SYS loaded on micro }
Function AnsiSysLoaded : Boolean;
Var
  _AX : Word;
  Regs: Registers;
begin
   Regs.AX := $1a00;
   Intr($2f,Regs);
   _Ax := Regs.AX;
   ANSISysLoaded := Lo(_AX) = $FF
end;

{ ------------------------------------------------------------------------
                              DETECTANSI
 Detect whether the remote user has ANSI support For initial Graphic mode.
 ------------------------------------------------------------------------ }
Function DetectAnsi : Boolean;
Var
  AnsiDetected : Boolean;
  AnsiChar     : Char;
begin
  AnsiDetected := False;
  If (OrgCarr) then                 { not sysop_local then }
  begin
    Fossil.ModemPut(#27+'[6n');    { Esc[6n (Cursor Position Request) }
    Fossil.FlushBuff;
    Crt.Delay(2000);               { waits For response (2 second) }
    If (Fossil.SerialChar) then    { if modem buffer is not empty }
    begin
      AnsiChar := Fossil.Receive;
      If (AnsiChar in [#27,'0'..'9','[','H']) then
        AnsiDetected := True;
    end;
    Crt.Delay(1000);      { Pause 1 second }
    Fossil.PurgeLine;     { Purge input buffer }
    Fossil.PurgeOutput;   { Make sure nothing is in output buffer }
  end
  else
    { if local, check For ANSI.SYS loaded }
    AnsiDetected := AnsiSysLoaded;
    { here you might wanna say:
      if not AnsiSysLoaded then UseAnsiSimulator := True; }

  If AnsiDetected then
    PrintLn('ANSI Graphics detected.')
  else
    PrintLn('ANSI Graphics disabled.');
  DetectAnsi := AnsiDetected;
end;
