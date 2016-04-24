(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0020.PAS
  Description: Clock 2
  Author: AMIR FRENKEL
  Date: 01-27-94  12:23
*)

{
> H E L P!!!  I need help with the timer Interrupt... I guess?  Here
> is what I would like to do, I want to have the Time in the upper right
> hand corner updated by the second.  I was told that I need to "hook in
> to the timmer interrupt" but, how do I do that?  Any help would be
> appreciated.  And if possible make it as non technical as possable.

Here is just the program your looking for!
}
Program Clock_demo;
{$M $400 ,0 ,0}                       { Stack Size $400 , No Heap      }
{$F+}
Uses Dos ,Crt;
Var
    Count:Byte;                       { Counts Seconds                }
    Time:Longint  Absolute $40:$6C;   { Bios Keeps Clock Time Here    }
    Old1Cint:Procedure;               { Linkage To Old 1C Interrupt   }


{ Every 18 Pulses Shows Time At The Left Corner Of Screen }
Procedure Get_Time;Interrupt;
Var X ,Y:Byte;
    Hour ,Minute ,Sec:Word;
Begin
  Inc(Count);
  If Count =18 Then                        { Every Second 18.2 Pulses      }
    Begin
      Count:=0;
      X:=Wherex;                           { Save Cursor Place             }
      Y:=Wherey;
      Hour:=Time Div 65520;                { Calculate Hours. In Each Hour }
                                           { 18.2 * 60 * 60 Pulses         }
      Minute:=Time Mod 65520 Div 1092;     { Calculate Minutes. In Each    }
                                           { Minute 18.2 * 60 Pulses       }
      Sec:=Round((Time Mod 65520 Mod 1092) / 18.2) Mod 60; { Seconds       }
      Gotoxy(70 ,1);                       { Left Corner Of Screen         }
                                           { Write time                    }
      If Hour<10 Then
        Write(0,Hour,':')
      Else
        Write(Hour,':');
      If Minute<10 Then
        Write(0,Minute,':')
      Else
        Write(Minute,':');
      If Sec<10 Then
        Write(0,Sec)
      Else
        Write(Sec);
      Gotoxy(X ,Y);                        { Restore Cursor Position       }
    End;
  Inline($9C);                             { Pushf - Push Flags            }
  Old1Cint;                                { Link Old 1C Procedure         }
End;

Begin                          { Of Main Program                     }
  Count:=0;                    { Clock Pulses Counter                }
  Getintvec($1C ,@Old1Cint);   { Save Old 1C Interrupt Vector        }
  Setintvec($1C ,@Get_Time);   { Insert Current Interurupt Procedure }
  Keep(0);                     { Terminate And Stay Resident - Tsr   }
End.


