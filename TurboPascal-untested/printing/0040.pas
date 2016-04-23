{
>If anyone could tell me how to disable [Print Screen] from within a
>text-based program, I would appreciate it.  Thanks, - Jeff Napier, Another
>Company -

 For that you can trap int 5h(Print Screen interrupt) Here is a program I
wrote for someone on another network that will show you the basics of how
it can be done:

nstn1410@fox.nstn.ca
}
PROGRAM DisableInt05h;          { Dec 13/93, Greg Estabrooks.           }
USES CRT,                       { IMPORT Clrscr,KeyPressed.             }
     DOS;                       { IMPORT SetIntVec,GetIntVec.           }
VAR
   OldInt05   :POINTER;         { Holds the old address of INT 05h.     }
   NumPressed :WORD;            { The number of times PrtScr was pressed.}
   Misc       :WORD;

{$F+}                           { Force FAR calls.                      }
PROCEDURE NewInt05; ASSEMBLER;
ASM
  Push DS                       { Push DS onto stack.                   }
  Mov AX,Seg @Data              { Now point DS to our data segment.     }
  Mov DS,AX
  Add NumPressed,1              { Add one to counter.                   }
  Pop DS                        { Pop DS off stack.                     }
  IRet                          { Force a return and pop flags off stack.}
END;{NewInt05}
{$F-}                           { Back to normal.                       }

BEGIN
  NumPressed := 0;             { Clear number count.                    }
  Clrscr;                      { Clear the screen.                      }
  GetIntVec($05,OldInt05);     { Save Old Interrupt vector.             }
  SetIntVec($05,@NewInt05);    { Point to our trap.                     }
  Misc := 0;                   { Clear Counter.                         }
  REPEAT                       { Loop Until a key other than PrtScr is  }
                               { pressed.                               }
    GOTOXY(1,1);               { Always show info at top corner.        }
    Write(Misc:8,'...  You have pressed PrtScr ',NumPressed:3,' times.');
    INC(Misc);                 { Increase counter to show a change.     }
  UNTIL KeyPressed;
  SetIntVec($05,OldInt05);     { Restore Old Interrupt vector.          }
END.{DisableInt05h}
