{
RANDALL WOODMAN

NOTE: There is a call to a Procedure called YNWin.  It is defined as:
     YNWin(s : String; Var ch : Char; Color : ColorSet);
Color set comes from the ObjectProfessional package from TurboPower software.
YNWin is derived from one of their Objects.  Basically it pops up a Window,
displays the String, s, in the colors specified, and waits For a Y or N Char
from the user.  It returns that result in CH.
     I did not include YNWin in this post.  However, you can easily Write
a Procedure to take it's place.  I only left the calls in place to show you
what I do when I do need interaction from the user.
     The Printer codes used are specific to an Epson compatible Printer.
Check your user manual For other Printer support.
}

Unit IThinkClintonsDefecetReductionPackageSucks;

Uses
  Dos;

Const
  TimedOut   = $01;  { Used to determine the Type of Printer error }
  IOError    = $08;
  OutOfPaper = $20;
  NotBusy    = $80;
  TestAll    = TimedOut+IOError+OutOfPaper;

Var
  PrnStatus : Byte;

Function PrinterReady : Boolean;
{ checks the status of the Printer and returns True if ready      }
{ to recieve a Character                                          }
{ This Function will return the status of your Printer.  Status   }
{ should be interpreted as follows:  (x'90' (d'144') is "Ready"): }
{ $01 = Printer Time-out          $02 = Not Used                  }
{ $04 = Not Used                  $08 = I/O Error                 }
{ $10 = Printer Selected          $20 = Out Of Paper              }
{ $40 = Acknowledge               $80 = Not Busy                  }

Var
   Regs : Registers;
   TempStatus : Byte;
begin
  With Regs Do
  begin
    DX := 0;
    AX := $0200;
    Intr($17,Regs);
    PrnStatus := Hi(AX);
    TempStatus := PrnStatus;
    PrinterReady := (TempStatus and TestAll = $00);
  end;
end;

Procedure GetPrnError(Var ESC : Boolean);
{ gets the error that occured With the Printer and gives the user a chance to }
{ correct the problem and continue. }
Var
  CH : Char;
begin
  Repeat
    PrnStatus := PrnStatus and TestAll;
    Case PRnStatus OF
      TimedOut   : YNWin('Printer timed out.  Retry??? (Y/N)',Ch,Mycolor);
      IOError    : YNWin('An IOError has occured.  Retry??? (Y/N)',CH,Mycolor);
      OutOfPaper : YNWin('Printer out of paper.  Retry??? (Y/N)',CH,Mycolor);
    else
      YNWin('A Print Device Error has occured.  Retry??? (Y/N)',CH,Mycolor);
    end; { Case }
    if CH = 'N' then
      esc := True;
  Until ESC or PrinterReady;
end;

Function EscapePushed : Boolean;
{ Checks the keyboard buffer For a Character and test to see if it was the }
{ Esc key.  if it was it returns True else it returns False.               }
Var
  CH : Char;
begin
  if KeyPressed then        { Check the keyboard buffer For a Character }
  begin
    CH := ReadKey;          { if Character then check it }
    CH := UpCase(CH);
    EscapePushed := (Ch = Chr(27));
  end
  else
    EscapePushed := False;
end;

Procedure ConfirmQuit(Var ESC : Boolean);
{ confirms that the user wants to quit printing }
Var
  CH : Char;
begin
  YNWin('Cancel all print jobs? (Y/N)',Ch,Mycolor);
  ESC := (CH = 'Y');
end;

Procedure PrintCh(CH : Char; Underline : Boolean; Var OK : Boolean);
{ Writes a single Character to the Printer }
begin
  if UnderLine then
    {$I-} Write(LST, #27#45#1, CH, #27#45#0) {$I+}
  else
    {$I-} Write(lst,CH); {$I+}
  OK := (IOResult = 0);
end;

Procedure MakeLine(Start, Stop : Integer; Return : Boolean; Var ESC : Boolean);
{ Draws a line on the paper starting at Start and ending at Stop. }
Var
  PrnReady,
  Ok       : Boolean;
begin
  PrnReady := True;
  Repeat
    PrnReady := PrinterReady;
    if not PRnReady then
      GetPrnError(ESC);
  Until PrnReady or ESC;

  PrnReady := True;
  While prnReady and not Esc and (Start <> Stop + 1) DO
  begin
    prnReady := PrinterReady;  { do three test to be sure }
    if not PRnReady then
      GetPrnError(ESC);
    if not ESC then
      PrintCH('_',False,OK);
    if not ESC then
      if EscapePushed then
        ConfirmQuit(ESC);
    if OK then
      Inc(Start);
  end;
  if not Esc and PrnReady and RETURN then
    {$I-} Writeln(LST); {$I+}
end;

Procedure WriteStr(TheStr : String; Return, UnderLine : Boolean;
                   Var ESC : Boolean);
Var
  PrnReady,
  OK       : Boolean;
  I        : Byte;
begin
  Repeat
    PrnReady := PrinterReady;
    if not PRnReady then
      GetPrnError(ESC);
  Until PrnReady or ESC;
  I := 1;

  While PrnReady and not Esc and (I <> Length(theStr)+1) DO
  begin
    PrnReady := PrinterReady;
    if not PRnReady then
      GetPrnError(ESC);
    if not ESC then
      PrintCh(theStr[I], UnderLine, OK);
    if not esc then
      if EscapePushed then
        confirmQuit(Esc);
    if OK then
      Inc(I);
  end;
  if PrnReady and Not ESC And RETURN then
    {$I-} Writeln(LST); {$I+}
end;
