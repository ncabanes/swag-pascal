
{      This Unit is a replacement for the Printer unit that   }
{ came with Turbo Pascal Version 4.0 and 5.0.  Its purpose is }
{ fourfold.                                                   }
{                                                             }
{ First: It will allow a user to change the printer port that }
{ the LST file is writing to on the fly.  This takes the      }
{ place of LstOutPtr and the routine on page 369 of the Turbo }
{ Pascal Version 3.0 manual.                                  }
{                                                             }
{ Second: This unit will free the programmer from the need to }
{ check to see if the printer is ready to accept characters.  }
{ If the printer is not ready, the unit will place a line on  }
{ the screen prompting the user to fix the printer and press  }
{ a key.  This process will continue until the printer is     }
{ made ready or the user Aborts or Ignores the printing       }
{ operation.  NOTE: BIOS does not return correct error codes  }
{ for Non-Existent printers or printer ports because the      }
{ printer is not there to return any error codes at all.      }
{                                                             }
{ Third: This unit will also circumvent DOS's stripping of a  }
{ Ctrl-Z ($1A, the End Of File character) when writing to the }
{ printer as an ASCII device. Ctrl-Z was usually sent as part }
{ of a graphics string to a printer.  In version 3.0 of Turbo }
{ Pascal, an ASCII device was opened in binary mode.  In      }
{ version 4.0, an ASCII device is opened in ASCII mode and    }
{ DOS thus strips a Ctrl-Z.                                   }
{                                                             }
{ Fourth: This also provides a good example of a Text file    }
{ device driver.                                              }
{ Warning: This Driver has not been tested on a non-buffered  }
{ printer, as the smallest buffer I could find was 80 chars.  }

{      Type this to a file called PRINTERR.PAS                }

{$R-}
Unit PrintErr;

Interface

Uses DOS,CRT;

Var
  LST : Text;                      { Public LST file variable }

Procedure SetPrinter( Port:Byte );
{      SetPrinter sets the printer number to Port where Port  }
{ is 'n' in 'LPTn'.  ie.  To write to LPT1: SetPrinter(1),    }
{ for LPT2: SetPrinter(2).  SetPrinter changes the Port that  }
{ subsequent Write operations will write to.  This lets you   }
{ change the printer that you are printing to on the fly.     }

Implementation

Function PrinterCheck( PortNum, Error:Byte; Var Pos:Word):Boolean;
Var
  Response : Char;
  Regs     : Registers;
  OldTextAttr : Byte;
  NewPos : Word;
Begin
  Response := 'R';                { Assume Retry              }
  NewPos := Pos;                  { Assume no Error           }
  While ((Error and $29) <> 0) and (Response = 'R') do
  Begin
    NewPos := Pos - 1;            { Decrement to reprint char }
    OldTextAttr := TextAttr;      { Save Old Attribute        }
    TextAttr := TextAttr or $80;  { Turn on Blink Bit         }
    Write( #13'Printer Not Ready!   ' );     { Write the user }
    Write( 'A) Abort, R) Retry, I) Ignore '#13 ); { a message }
    TextAttr := OldTextAttr;      { Restore Old Attribute     }
    Response := Upcase( Readkey );{ Read Char and upcase it   }
    ClrEol;                       { Clear Line                }
    If Response = 'A' then        { If Abort then exit        }
      halt( 160 );                { Note: Uses Exit Proc.     }
    If Response = 'R' then
    Begin
      Regs.AH := 2;                 { Code for Check Status   }
      Regs.DX := PortNum;           { Printer port number -1  }
      Intr($17,Regs);               { Call printer service    }
      Error := Regs.AH;             { save Printer Error Code }
                                    { 00000001 = Time Out     }
                                    { 00000010 = Unused       }
                                    { 00000100 = Unused       }
                                    { 00001000 = I/O Error    }
                                    { 00010000 = Selected     }
                                    { 00100000 = Out of Paper }
                                    { 01000000 = Acknowledge  }
                                    { 10000000 = Not busy     }
    End;
  End;
  PrinterCheck := Response = 'R';
  Pos := NewPos;
End;

Function PrinterReady(PortNum:Byte):Boolean;
Var
  Ready    : Boolean;
  Dummy    : word;
  Regs     : Registers;
Begin
    Regs.AH := 2;                   { Code for Check Status   }
    Regs.DX := PortNum;             { Printer port number -1  }
    Intr($17,Regs);                 { Call printer service    }
    PrinterReady := PrinterCheck( PortNum, Regs.AH, Dummy )
End;

{      The following routines MUST be FAR calls because they  }
{ are called by the Read and Write routines.  (They are not   }
{ Public (in the implementation section) because they should  }
{ only be accessed by the Read and Write routines.)           }

{$F+}

{      LSTNoFunction performs a NUL operation for a Reset or  }
{ Rewrite on LST (just in case).                              }

Function LSTNoFunction( Var F: TextRec ): integer;
Begin
  LSTNoFunction := 0;                    { No error           }
end;

{      LSTOutputToPrinter sends the output to the Printer     }
{ port number stored in the first byte or the UserData area   }
{ of the Text Record.                                         }

Function LSTOutputToPrinter( Var F: TextRec ): integer;
var
  Regs: Registers;
  P : Word;
begin
  With F do
  Begin
    P := 0;
    If PrinterReady( F.UserData[1] ) Then
    While (P < BufPos) do
    Begin
      Regs.AL := Ord(BufPtr^[P]);
      Regs.AH := 0;
      Regs.DX := UserData[1];
      Intr($17,Regs);
      Inc(P);
      If Not PrinterCheck( F.UserData[1], Regs.AH, P ) then
        P := BufPos;
    End;
    BufPos := 0;
  End;
  LSTOutputToPrinter := 0              { No error           }
End;

{$F-}

{      AssignLST both sets up the LST text file record as     }
{ would ASSIGN, and initializes it as would a RESET.  It also }
{ stores the Port number in the first Byte of the UserData    }
{ area.                                                       }

Procedure AssignLST( Port:Byte );
Begin
  With TextRec(LST) do
    begin
      Handle      := $FFF0;
      Mode        := fmOutput;
      BufSize     := SizeOf(Buffer);
      BufPtr      := @Buffer;
      BufPos      := 0;
      OpenFunc    := @LSTNoFunction;
      InOutFunc   := @LSTOutputToPrinter;
      FlushFunc   := @LSTOutputToPrinter;
      CloseFunc   := @LSTOutputToPrinter;
      UserData[1] := Port - 1;  { We subtract one because }
  end;                          { DOS Counts from zero.   }
end;


Procedure SetPrinter( Port:Byte ); { Documented above     }
Begin
  With TextRec(LST) do
    UserData[1] := Port - 1;{ We subtract one because DOS }
End;                        { Counts from zero.           }

Begin  { Initialization }
  AssignLST( 1 );           { Call assignLST so it works  }
end.                        { like Turbo's Printer unit   }


---------------------------------------------------------------

************ Type this to a Second file ************

Program Test_PrintErr_Unit;

Uses PrintErr;

Begin
  Writeln(     'Testing...Printer #1');
  Writeln( LST,'Testing...Printer #1');
  SetPrinter( 1 );
  Writeln(     'Testing...Same Printer');
  Writeln( LST,'Testing...Same Printer');
  SetPrinter( 2 );
  Writeln(     'Testing...Printer #2');
  Writeln( LST,'Testing...Printer #2');
End.
