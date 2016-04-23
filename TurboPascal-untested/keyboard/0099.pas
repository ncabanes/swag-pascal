{ from SWAG, STUFF KYBD BUF by Rob Perelman, at beginning of KEYBOARD.SWG
  section.  Modified by Bill Brachhold ( willie@hal.eng.ufl.edu ) to make
  into a pseudo-Exec command.  It is sorta like Exec but is NOT a
  shell-type like Exec. It basically stuffs the keyboard buffer with
  the name of the program you want to run, then exits to DOS where DOS
  'finds' the program name and executes it.  Its big advantage is that it
  consumes NO memory when the other program starts.  Obviously, to get back
  to the first program, you would have to 'ExecProg' to it also.

From: Bill Brachold <willie@hal.eng.ufl.edu>
}

Unit ExecNML; { EXEC with No Memory Loss }

INTERFACE

Type
  String80 = string[80];

Procedure ExecProg( ProgNm : string80 );
{ Note: ProgNm can be full drive/path/filename if you want }

IMPLEMENTATION

Uses
  CRT;

Procedure ExecProg(ProgNm : string80 );
{ Note: not set up to do EXTENDED keycodes but could easily be made to do so }
Const
  Code = 0; { implies standard keys being passed, NOT extended keycodes }
Type
  BufType = Array[30..62] of Byte;
Var
  Head    : Integer Absolute $0000 : $041A; { Location of head of buffer }
  Tail    : Integer Absolute $0000 : $041C; { Location of tail of buffer }
  KBDBuf  : BufType absolute $0000 : $041E; { Absolute location of buffer }
  i, TempTail : Integer; { Temporary holding of Tail  }
Begin
  ProgNm := ProgNm + #13; { add CR to simulate USER pressing ENTER key }
  for i := 1 to Length(ProgNm) do { stuff in program name + ENTER key }
    begin
      TempTail := Tail;     { Store the Temporary Tail   }
      Tail := Tail + 2;     { Increment Tail to next pos }
      If Head = Tail Then   { Is the buffer full?        }
        Begin
          Tail := TempTail; { Reset to previous value    }
          Sound(440);       { Beep the user              }
          Delay(200);       { Delay for the beep         }
          Sound(880);       { Beep the user              }
          Delay(200);       { Delay for the beep         }
          NoSound;          { Turn off the sound         }
        End
      Else
        Begin
          KBDBuf[TempTail] := Ord(ProgNm[i]);  { Put the ASCII value in buf }
          KBDBuf[TempTail + 1] := Code; { Put extended keypress valu }
          If Tail > 60 then Tail := 30; { Last position. Wrap to 1st position }
        End;
    end; { for }
  Halt; { You must HALT, otherwise, DOS doesn't start scanning keyboard
          buffer to 'find' the command you just stuffed into it. }
End;

End.
