{
ROB PERELMAN

> I want to put the character and scan code for ALT-V in the keyboard buffer.
> In fact I would like to put it in there twice. I need it to be in the
> buffer so that when my program terminates the parent process will act on
> that key.

{
 If this is being used with Turbo Pascal Version 3.0, you MUST set
 the C and U compiler directives to MINUS!
 If this is being used with Turbo Pascal Version 4.0, then set the
 CheckBreak variable  of the CRT unit to FALSE!
}

Uses
  Crt;

Type
  BufType = Array[30..62] of Byte;

Var
  Head    : Integer Absolute $0000 : $041A;    { Location of head of buffer  }
  Tail    : Integer Absolute $0000 : $041C;    { Location of tail of buffer  }
  KBDBuf  : BufType absolute $0000 : $041E;    { Absolute location of buffer }
  S       : String[80];                        { Input string                }

Procedure StufftheBuff (Ch : Char; Code : Byte);
Var
  TempTail : Integer;                          { Temporary holding of Tail  }
Begin
  TempTail := Tail;                           { Store the Temporary Tail   }
  Tail := Tail + 2;                           { Incriment Tail to next pos }
  If Head = Tail Then                         { Is the buffer full?        }
  Begin
    Tail := TempTail;                        { Reset to previos value     }
    Sound(440);                              { Beep the user              }
    Delay(400);                              { Delay for the beep         }
    NoSound;                                 { Turn off the sound         }
  End
  Else
  Begin
    KBDBuf[TempTail] := Ord(Ch);              { Put the ASCII value in buf }
    KBDBuf[TempTail + 1] := Code;             { Put extended keypress valu }
    If Tail > 60 then                         { Last position. Wrap?       }
      Tail := 30;                             { Wrap to 1st position       }
  End;
End;

Begin
  ClrScr;                                     { Clear the Screen           }
  StufftheBuff ( 'D',0 );                     { Start stuffing the buffer  }
  StufftheBuff ( 'I',0 );                     { Another stuff of the Buffer}
  StufftheBuff ( 'R',0 );                     {    "      "    "  "    "   }
  StufftheBuff ( #13,0 ); { CR }              { Stuff a carriage return    }
End.
