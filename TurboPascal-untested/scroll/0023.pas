{
|> I need a Text scroller for a message (greater than 255 chars??) .. I have one
|> that works right now..but I use the getintvec and setintvec with $8 which is
|> a programmable timer i think..but im afraid that it is slowing down my
|> computer clock, and its not consistent in its speed..I also need to be doing
|> other things (scrolling through options with arrow keys) while the scrolling
|> is going on..

There are a number of ways to go about your problem.  But it depends
on whether you'd like the scrolling to be consistent in its speed or
you don't like to slow down your system by hooking Int 08h or 1Ch.
For a more consistent loop, you would have to use the timer int (08h
or 1Ch).  Or if you could call an "update" routine very often, then
you could do away with the timer int.  If the refresh rate is
relatively slow, you could still use either method - just make sure
that your update routine is somewhat fast.

Anyway, I'll let you decide on which technique to use on providing the
refresh calls.  If you need some more help, just drop me a line.
Below is a sample code that you could probably use for the update:
}

Uses Crt;

Var CurrIndex  : Word;     { current starting position of string       }
    ScreenLoc  : Pointer;  { location of scroll bar in video memory    }
    ScrollSize : Word;     { size of scroll bar (in columns)           }

Procedure Setup(Col, Row, ScrollSize : Word; Var ScreenLoc : Pointer);
Var Seg1, Ofs1 : Word;
Begin
   { we're assuming an 80 column text mode }
   Ofs1 := (Row-1)*160 + ((Col-1)*2);  

   { determine whether it's mono or colored }
   If (Mem[$40:$49] = 7) then Seg1 := $B000
     else Seg1 := $B800;

   ScreenLoc := Ptr(Seg1,Ofs1);  { I'm not sure about the syntax }
                                 { better check the online help  }
End;


Procedure Update;Assembler;
ASM
   CLD
   LES  DI, ScreenLoc    { ES:DI is where the scroll bar is in memory  }
   MOV  CX, ScrollSize

   MOV  SI, CurrIndex
   OR   SI, SI           { is it our first time to display the string? }
   JZ   @WriteString

   DEC  CX
@ShiftLeft:              { let's shift the chars one position to the   }
   MOV  AL, ES:[DI+2]    { left... ( we don't care about the attr)     }
   STOSB
   INC  DI               { skip the attribute position                 }
   LOOP @ShiftLeft       { continue up until the end of scroll bar     }

   MOV  AL, CS:[SI]      { see what's the next char to append...       }
   OR   AL, AL           { are we at the end of the string ?           }
   JNZ  @NotEndOfStr     { if not, just proceed.                       }
   MOV  SI, Offset @Message  { otherwise, point back to the first char }
   MOV  AL, CS:[SI]      { and get it                                  }
@NotEndOfStr:
   STOSB                 { put new char at tail of scroll bar          }

   INC  SI               { adjust index -- so that we know what's the  }
   JMP  @SaveIndex       { next char to append next time...            }

@WriteString:            { routine to display message the first time   }
   MOV  SI, Offset @Message
@NextChar:
   MOV  AL, CS:[SI]
   OR   AL, AL
   JZ   @WriteString     { if message is shorter than scroll, restart }
   STOSB                 { put char in video memory                   }
   INC  DI               { skip the attribute part                    }
   INC  SI               { adjust SI to point to next char in message }
   LOOP @NextChar        { fill-up all of scrollbar                   }

@SaveIndex:
   MOV  CurrIndex, SI    { Save index.  We need it again later        }  
   JMP  @Exit

@Message:
   DB   'This is a sample message...'  { put your text message here   }
   DB   0                              { terminate it with NULL       }
@Exit:
End;

Var Fedup : Boolean;

Begin
   ScrollSize := 40;  { adjust to your liking }

   { scroll bar at first row, 20th column }
   Setup(20,1,SCrollSize,ScreenLoc);

   CurrIndex := 0;   { initialize index }

   { sample code to test... I hope it works :-) }
   ClrScr;
   Repeat
     Update;
     Delay(100);     { must put some delay or something      }
                     { otherwise, you won't be able to read  }
                     { message... unless you're superman :-) } 
     { do some other stuffs }

     Fedup := (KeyPressed) and (ReadKey = #27);
   Until (Fedup);
End.

Note that the example about is not fully tested.  Most of my post here
are made from scratch so I don't know if it would fit your needs.

Also, sorry for the term "scroll bar".  I know it means something else
but I can't think of something short but appropiate term.

Like I said, you have to judge whether to use a timer int or not.  But 
if you could put the update routine in a loop that it gets to be executed in
regular intervals, that would be enough.

Happy programming...

YO!
ydeeps
--
Erwin D. Paguio
http://rh.iist.unu.edu/~ep/ydeeps.html
Pascal and ASM Enthusiast
