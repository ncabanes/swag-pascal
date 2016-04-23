
{      This Unit is a replacement for the Write statment      }
{ came with Turbo Pascal Version 4.  It's purpose is to allow }
{ you to write to the screen without scrolling it.  Even      }
{ 25,80.  WARNING this routine will not scroll the screen!    }
{                                                             }
{      This also provides a good example of a Text file       }
{ device driver.                                              }
{                                                             }
{      Type this to a file called WriteNLF.PAS                }

Unit WriteNLF;

Interface

Uses DOS,Crt;

Var
  NLF : Text;                      { Public NLF file variable }

Implementation

{      The following routines MUST be FAR calls because they  }
{ are called by the Read and Write routines.  (They are not   }
{ Public (in the implementation section ) because they should }
{ only be accessed by the Read and Write routines.            }

{$F+}

{      NLFNoFunction performs a NUL operation for a Reset or  }
{ Rewrite on NLF (Just in case)                               }

Function NLFNoFunction( Var F: TextRec ): integer;
Begin
  NLFNoFunction := 0;                    { No error           }
end;

{      NLFOutputToPrinter sends a the output to the Printer   }
{ port number stored in the first byte or the UserData area   }
{ of the Text Record.                                         }

Function NLFOutputToPrinter( Var F: TextRec ): integer;
var
  Regs: Registers;
  P,                    { Buffer Pointer                     }
  Cursor,               { Current Cursor Position            }
  DisplayPage: word;    { Current Display Page               }

begin
  With F do
  Begin
    P := 0;

    Regs.AH := 15;                { Get Current Vidio State  }
    Intr($10,regs);
    DisplayPage := Regs.BH;       { Get Active Display Page  }

    Regs.AH := 3;                 { Get Cursor Position Code }
    Regs.BH := DisplayPage;       { Display Page             }
    Intr($10,Regs);
    Cursor := Regs.DX;            { Get Cursor Position      }

    While (P < BufPos) do
    Begin
      Regs.AH := 9;               { Display Char/Attr Code   }
      Regs.AL := Ord(BufPtr^[P]); { Character to Write       }
      Regs.BH := DisplayPage;     { Display Page             }
      Regs.CX := 1;               { # Characters to Write    }
      Regs.BL := TextAttr;        { Current Text Attribute   }
      Intr($10,Regs);
      Inc(P);
      if P < BufPos then
      Begin
        Regs.AH := 2;             { Set Cursor Position Code }
        Regs.BH := DisplayPage;   { Display Page             }
        Inc(Cursor);              { Move Cursor              }
        Regs.DX := Cursor;        { Set New Cursor Position  }
        Intr($10,Regs);
      end;
    end;
    BufPos := 0;
  End;
  NLFOutputToPrinter := 0;        { Device write Fault }
End;

{$F-}

{      AssignNLF both sets up the NLF text file record as     }
{ would ASSIGN, and initializes it as would a RESET.          }

Procedure AssignNLF;
Begin
  With TextRec(NLF) do
    begin
      Handle      := $FFF0;
      Mode        := fmOutput;
      BufSize     := SizeOf(Buffer);
      BufPtr      := @Buffer;
      BufPos      := 0;
      OpenFunc    := @NLFNoFunction;
      InOutFunc   := @NLFOutputToPrinter;
      FlushFunc   := @NLFOutputToPrinter;
      CloseFunc   := @NLFOutputToPrinter;
  end;
end;

Begin  { Initilization }
  AssignNLF;                { Call assignNLF so it works  }
end.                        { like Turbo's Printer unit   }


************ Type this to a Second file ************

Program Test_WriteNLF;

Uses WriteNLF,crt;

Begin
  clrscr;
  Writeln(     'Testing...');
  GotoXY( 1,25 );
  Write( NLF,'1234567890123456789012345678901234567890',
             '1234567890123456789012345678901234567890');
  readln;
End.

