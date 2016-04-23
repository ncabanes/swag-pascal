{
   There was a discussion about  how to trap  floating point errors
in  TP.  Here  is  the   solution that traps   any kind of run-time
errors.  The idea is not mine. I saw it in a russian  book about TP
and OOP.

   The idea is quite simple.  Instead of trying to trap all kind of
errors, we  can let TP to do  the job for  us.   Whenever  TP stops
execution of the  program ( because   of a run  time  error or just
because  the program  stops in a  natural  way )  it   executes the
default procedure of exit : ExitProc.  Then TP checks the status of
two variables from  the SYSTEM unit  : ErrorAddr and  ExitCode.  If
there was a run  time error then ErrorAddr  is not NIL and ExitCode
containes the run time error code. Otherwise ExitCode containes the
errorlevel  that  will be    set  for  DOS and  ErrorAddr  is  NIL.
Fortunatly  we can easily  redefine   the  ExitProc,   and  thus to
overtake the control from TP. The problem is that we got to be able
to get back or to jump to any point  of the program  ( even to jump
inside a procedure / function). The author of the book claimed that
he took his routines from Turbo Professional.

   Well, there are two files you are gonna need. Save the first one
as JUMP.PAS Compile it as a unit. The second one is a short program
that shows  how to use  it. It  asks for   two numbers, divides the
first  by the second and takes  a  natural logarithm of the result.
Try to divide by zero, logarithm of a negative number. Try entering
letters instead of numbers and see how the program recovers.

   The trapping   works  fine under Windows/Dos.   To  run  it with
WINDOWS recompile the JUMP unit for Windows target. Then add WinCrt
to the Uses statement and remove Mark/Release lines ( because there
is no Mark/Release for Windows ).
}

Unit Jump;
Interface
Type JumpRecord = Record
                        SpReg,
                        BpReg  : Word;
                        JmpPt  : Pointer;
                  end;

Procedure SetJump ( Var JumpDest : JumpRecord );
{Storing SP,BP and the address}
inline(
       $5F/                   {pop di           }
       $07/                   {pop es           }
       $26/$89/$25/           {mov es:[di],sp   }
       $26/$89/$6D/$02/       {mov es:[di+2],bp }
       $E8/$00/$00/           {call null        }
                              {null:            }
       $58/                   {pop ax           }
       $05/$0C/$00/           {add ax,12        }
       $26/$89/$45/$04/       {mov es:[di+4],ax }
       $26/$8C/$4D/$06);      {mov es:[di+6],cs }
                              {next:            }

Procedure LongJump ( Var JumpDest : JumpRecord );
{Restore everything and jump}
inline(
       $5F/                   {pop di           }
       $07/                   {pop es           }
       $26/$8B/$25/           {mov sp,es:[di]   }
       $26/$8B/$6D/$02/       {mov bp,es:[di+2] }
       $26/$FF/$6D/$04);      {jmp far es:[di+4]}

Implementation
End.


------------------------------try.pas------------------------------

Program Try;
Uses Jump;                                 {Uses Jump,WinCrt;}
Var
   OldExit : Pointer;
   MyAddr  : JumpRecord;
   MyHeap  : Pointer;

   a1,a2,
   a3,a4   : real;


{$F+}
Procedure MyExit;
{You can add your error handler here}
Begin
     If ErrorAddr<>Nil Then Begin
        case ExitCode of
             106 : Writeln('Invalid numeric format');
             200 : Writeln('Division by zero');
             205 : Writeln('Floating point overflow');
             206 : Writeln('Floating point underflow');
             207 : Writeln('Invalid floating point  operation');
             else  Writeln('Hmmm... How did you do that ?');
        end;
        ErrorAddr:=Nil;
        LongJump(MyAddr);
     end;
     ExitProc:=OldExit;
End;
{$F-}

Begin
     OldExit:=ExitProc;
     Mark(MyHeap);        {Just an example of how to restore the heap }
                          {Actually we don't have to do that in       }
                          {this program, because we dont use heap     }
                          {at all. But anyway here it goes            }
                          {Don't forget to remove when compiling this }
                          {for Windows                                       }


     SetJump(MyAddr);     {We'll get back here whenever a run time    }
                          {error occurs                               }
                          {This line should always be before          }
                          {     ExitProc:=MyExit;                     }
                          {Don't ask me why... It's much easier for me}
                          {to follow the rule then to understand it :)}
     ExitProc:=@MyExit;

     Release(MyHeap);      {restoring the heap after a run time error }
                           {Remove this if you are compiling it for   }
                           {Windows                                   }

                           {Try entering whatever you want at the     }
                           {prompt. It should trap every runtime error}
                           {you could possibly get.                   }
     Repeat
           Writeln;
           Write('Enter a number a1=');
           Readln(a1);
           Write('Enter a number a2=');
           Readln(a2);
           a3:=a1/a2;
           Writeln('a1/a2=',a3:10:5);
           a4:=ln(a3);
           Writeln('ln(a1/a2)=',a4:10:5);
     until a3=1;
end.
