(*
I am trying to figure out how to trap errors as they occur in my
Program and send messages to the user.. The most common error would be a
failed attempt to print but I don't know how to not stop the Program
when an error occurrs. You see, I don't want to have an {$I-},{$I+}
after every time the Printer prints..


not having any details of what you are doing, I'll take a stab in the dark.
Have an output routine and pass it a String.  The output routine would take
the String and sent it to the Printer.  ( Since you mentioned Printer, I
assume this is where you wish to send all output.)  Now have an output routine
For the screen.  Ah heck, here's an example. <g>  This is some code I wrote to
output Various things to the Printer.  No doubt some will claim to have better
solutions.  That's fine, but here's mine.  There is a routine you will see
called OUTCON(s : String; CH : Char);  It is a routine to send output to the
screen and inForm the user that there is a problem.  of course that's a
different topic then sending output to the Printer.  Hope this helps.
*)

Const
  TimedOut   = $01;  { Used to determine the Type of Printer error }
  IOError    = $08;
  OutofPaper = $20;
  notBusy    = $80;
  TestAll    = TimedOut+IOError+OutofPaper;
  NoUL       = False;
  UL         = True;

Var
  PrnStatus : Byte;

Function PrinterReady : Boolean;
{ checks the status of the Printer and returns True if ready to recieve a Chara
{ This Function will return the status of your Printer.  Status      }
{ should be interpreted as follows:  (x'90' (d'144') is "Ready"):    }
{ $01 = Printer Time-out          $02 = not Used                     }
{ $04 = not Used                  $08 = I/O Error                    }
{ $10 = Printer Selected          $20 = Out of Paper                 }
{ $40 = Acknowledge               $80 = not Busy                     }
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
      if TempStatus and TestAll = $00 then PrinterReady := True
        else PrinterReady := False;
    end;
end; { Function PrinterReady }

Procedure GetPrnError(Var ESC : Boolean);
{ gets the error that occured With the Printer and gives the user a chance to }
{ correct the problem and continue. }
Var
  CH : Char;
begin
  Repeat
    PrnStatus := PrnStatus and TestAll;
    Case PRnStatus of
      TimedOut   : OutCon('Printer timed out.  Retry??? (Y/N)',CH);
      IOError    : OutCon('An IOError has occured.  Retry??? (Y/N)',CH);
      OutofPaper : OutCon('Printer out of paper.  Retry??? (Y/N)',CH);
    else OutCon('A Print Device Error has occured.  Retry??? (Y/N)',CH);
    end;
    if CH = 'N' then esc := True;
  Until ESC or PrinterReady;
end;

Function EscapePushed : Boolean;
{ Checks the keyboard buffer For a Character and test to see if it was the   }
{ Esc key.  if it was it returns True else it returns False.                 }
Var
  CH : Char;
begin
  if KeyPressed then        { Check the keyboard buffer For a Character }
  begin
    CH := ReadKey;          { if Character then check it }
    CH := UpCase(CH);
    if Ch = Chr(27) then EscapePushed := True
    else EscapePushed := False;
  end
  else EscapePushed := False;
end; { EscapePushed }

Procedure ConfirmQuit(Var ESC : Boolean);
{ confirms that the user wants to quit printing }
Var
  CH : Char;
begin
  OutCon('Cancel all print jobs? (Y/N)',Ch);
  if CH = 'Y' then ESC := True
    else ESC := False;
end;

Procedure FFeed;
{ sends a Form feed command to the Printer }
begin
  Write(LST,#12);
end;

Procedure PrintCh(CH : Char;
                  Underline : Boolean;
                  Var OK    : Boolean);
{ Writes a Single Character to the Printer }
begin
  if UnderLine then {$I-} Write(LST, #27#45#1, CH, #27#45#0) {$I+}
  else {$I-} Write(lst,CH); {$I+}
  if Ioresult <> 0 then OK := False
    else OK := True;
end;

Procedure WriteStr(TheStr  : String;
                   Return, UnderLine : Boolean;
                   Var ESC : Boolean);
Var
  PrnReady : Boolean;
  OK       : Boolean;
  I        : Byte;
begin
  Repeat
    PrnReady := PrinterReady
    if not PrnReady then GetPrnError(ESC);
  Until PrnReady or ESC;
  I := 1;
  While PrnReady and not Esc and (I <> Length(theStr)+1) do
  begin
    PrnReady := PrinterReady
    if not PrnReady then GetPrnError(ESC);
    if not ESC then PrintCh(theStr[I],UnderLine,OK);
    if not esc then if EscapePushed then confirmQuit(Esc);
    if OK then Inc(I);
  end;
  if PrnReady and not ESC and RETURN then {$I-} Writeln(LST); {$I+}
end;
