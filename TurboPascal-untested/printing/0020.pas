PROGRAM PRINTCHK;

uses crt,dos,printer;
const
  lpt1=0;
  lpt2=1;
  lpt3=2;

  PrnReady = $90;
  OffLine = $00;
  OffLine2 = $10;             {NEW LINE}
  PaperOut = $20;
  PaperOut2 = $30;            {NEW LINE}
  HookedButOff = $80;         {NEW LINE}
  NoConnect = $B0;            {MODIFIED LINE}

  {NOCONNECT = $30 FOR SOME COMPUTERS BY STU}

  Function ChkPrinter(Printer:Word) :Word;
  Var Regs:Registers;

  Begin
    Regs.AH:=2;
    Regs.DX:=Printer;
    Intr($17,regs);
    ChkPrinter:=Regs.AH
  end;

  Procedure PrinterError(ErrorCode:BYTE);  ;NEW


  VAR
    C : BYTE;



  Begin
   ErrorCode := ErrorCode and $B0;       {NEW LINE}

   C := ERRORCODE SHL 6   {ALWAYS MEANS NOTHING CONNECTED}

   IF C > 0 THEN ERRORCODE = $B0; {ELEMINATES NO LPT3 AND NOTHING CONNECTED}


   Case ErrorCode of
    NoConnect           : WriteLn('Printer not connected');
    Offline,OffLine2    : WriteLn('Printer off line');     {Modified}
    PaperOut,PaperOut2  : WriteLn('Printer out of paper'); {Modified}
    HookedButOff        : WriteLn('Printer connected but turned off'); {New}
   else
    WriteLn('Printer error code: ',ErrorCode);
   end
  end;

  procedure TryPrinter;
  Begin
   {$I-}
   WriteLn(Lst,'Check Printer'+#12);
   {$I+}
   WriteLn(IOResult)
  End;

  Begin
   ClrScr;
   {TryPrinter;}
   If ChkPrinter(LPT1) = PrnReady then
    Writeln('Printer is Ready')
   else
    PrinterError(ChkPrinter(LPT1))
  end.