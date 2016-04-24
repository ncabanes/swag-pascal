(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0165.PAS
  Description: Source to tickertape
  Author: CHRIS AUSTIN
  Date: 11-22-95  13:32
*)

{
Heres some source to tickertape a string with a few demos I stumbled on :) If
you use this source or like it please tell me what you think and give me
credit :) Thanx...
---------> CUT <--------
}
Uses CRT;

    Procedure WaitRetrace; Assembler;
      Asm
        mov     dx,3dah
@L1:
        in      al,dx
        test    al,08h
        jne     @L1
@L2:
        in      al,dx
        test    al,08h
        je      @L2
      End;

Function TickerR(Instring : String) : String;
Var                                    {Ticks right.                        }
 TmpStr  : String;                     {Temporary string.                   }
 TmpChar : String;                     {Temporary character.                }
Begin                                  {Begin code.                         }
 TmpChar:=Instring[Length(Instring)];  {Grab the last character.            }
 Insert(TmpChar,Instring,1);           {Insert it before the 1st character. }
 Delete(Instring,Length(Instring),1);  {Delete the last character.          }
 TickerR:=Instring;                    {And return the result.              }
End;                                   {Exit function.                      }

Function TickerL(Instring : String) : String;
Var                                    {Ticks wrong ;) (left)               }
 TmpStr  : String;                     {Temporary string.                   }
 TmpChar : Char;                       {Temporary character.                }
Begin                                  {Begin code.                         }
 TmpChar:=Instring[1];                 {Grab the 1st character.             }
 Delete(Instring,1,1);                 {Delete the 1st character.           }
 TmpStr:=Instring+TmpChar;             {Tape the 1st onto the end.          }
 TickerL:=TmpStr;                      {And return the result.              }
End;                                   {Exit function.                      }

Var
 Tick1,Tick2 : String;                 {Holds the 2 demo strings.           }
 Msg         : String;                 {The message.                        }
Begin
ClrScr;
Msg:='     Press a key for 1st demo....While running - Press a key for next.';
Repeat
Msg:=TickerL(Msg);
WaitRetrace;
Write(Msg+#13);
Delay(200);
Until Keypressed;
ReadKey;
Tick1:='Howdy there everyone! How are ya all? Very good I hope....Well......Adios! ';
Tick2:=Tick1;
{Try uncommenting these down here... Pretty weird looking in #2!}
{Tick1:='░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓
█
▓▒░▒▓█▓▒';Tick2:='░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒
░▒▓█▓▒░▒▓█▓ ▒░▒▓█▓▒';}
Repeat
Tick1:=TickerR(Tick1);
Tick2:=TickerL(Tick2);
GotoXY(1,1);
WaitRetrace;
WriteLn(Tick1);
Write(Tick2);
Until Keypressed;
ReadKey;
ClrScr;
Msg:='     Press a key for 2nd demo....While running - Press a key for next.';
Repeat
Msg:=TickerL(Msg);
WaitRetrace;
Write(Msg+#13);
Delay(200);
Until Keypressed;
ReadKey;
Repeat
Tick1:=TickerR(Tick1);
Tick2:=TickerL(Tick2);
WaitRetrace;
WriteLn(Tick1);
WriteLn(Tick2);
Until Keypressed;
ReadKey;
ClrScr;
Msg:='     Press a key for 3rd demo....While running - Press a key to end.';
Repeat
Msg:=TickerL(Msg);
WaitRetrace;
Write(Msg+#13);
Delay(200);
Until Keypressed;
ReadKey;
Tick1:='Here we go to merge again...And again. ';
Tick2:=Tick1;
Repeat
GotoXY(1,1);
Tick1:=TickerR(Tick1);
Tick2:=TickerL(Tick2);
WaitRetrace;
Write(Tick1+'│'+Tick2+#10#13+Tick2+'│'+Tick1);
Until Keypressed;
ReadKey;
WriteLn(#10#10#13'█▓▒░ Bye! Remember to give me credit for this! :) ░▒▓█');
End.

