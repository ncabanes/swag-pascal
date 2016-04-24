(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0001.PAS
  Description: CLKTSR.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:09
*)

{$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 1024,0,0}
Uses Dos,
     clock;  { My clock ISR Unit in next message. }
Const
  IRet  : Word = $cf;
  IDStr : String[13]='TeeCee''s Clock';
Var
  p : Pointer;
begin
  GetIntVec($66,p);  { Int 66h is reserved For user defined interrupts }
  inc(LongInt(p),2);
  if String(p^) = IDStr then begin
    Writeln('TeeCee''s clock is already installed - you must be blind!');
    halt;
  end
  else begin
    Writeln('TeeCee''s clock is now installed For demo purposes only');
    SetIntVec($66,@IRet);   { IRet is obviously not an interrupt!      }
    { What we are actually doing is storing a Pointer to the IDStr     }
    { in the vector table - much like the way the Video font addresses }
    { are stored.                                                      }
    SwapVectors;
    Keep(0);
  end;
end.

(See the next message For the Unit Clock. )

Now that is definintely For demonstration purposes only!  It will work but has 
several serious shortcomings!

Firstly, it hooks the user defined interrupt $66 to allow any subsequent 
executions to determine if the Program is already installed.  It does this 
without making any checks as to whether or not something else already "owns" 
this vector. Not very smart!

Secondly, it provides no means to uninstall itself.  Mmmmm...  :-(

Thirdly, Graphics mode will cause problems.  Again - not terribly smart!

Finally, TSRs are not For the faint-of-heart or beginner. They are an 
extraordinarily complex and difficult part of Dos Programming and if you are 
serious about getting into TSRs then get as many good books as you can find 
that authoritively discuss the subject.  Buying a good commercial toolbox, such 
as Turbo Power's "TSRs Made Easy" is another smart move, as studying how the 
masters do it is one of the best ways to learn.

