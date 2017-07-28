(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0110.PAS
  Description: Pythagorean triples
  Author: MITCH PEABODY
  Date: 05-31-96  09:17
*)

{
DP> Howdy everyone, my computer science class at my high school is trying
DP> to work on the most efficient way to find all the pythagorean triples
DP> from 1 to a certain number, then dump them into a text file.  Currently,
DP> the fastest anyone has managed to get is 57 seconds for 1 to 1000.  The
DP> program would be considerably faster, but we are removing all duplicates
DP> and dilations.  In case you're wondering, a dilation would be: 6 8 10,
DP> which is just a dilation of 3 4 5.  IF anyone has any ideas (actual code
DP> would be nice) to help improve the speed of our programs, please drop me
DP> a message!!!  Thanks a lot.

  This kinda piqued my curiosity so I tried just what you were describing.
  I'm not much of a math wiz, but I came up with the following... it
  doesn't check for dilations... too lazy for that now but I looked
  at the pattern of dilations and there is a pretty definite pattern, so
  it shouldn't be too hard to put in.

  The output is not neat or anything, and it uses DOS redirection to
  output the numbers but I clocked it at 4 seconds on a DX2/66 in a full
  screen DOS session under windows 3.1 so it's pretty fast even for not
  checking dilations...

  The next message contains the rest of the code...
}

{ DEFINE DEBUG}                     { turn this on for debugging work   }
{$A-}                               { turn off alignment                }
{$B+}                               { complete boolean evaluations      }

{$IFNDEF DEBUG}                     { if not debugging program turn off }
{$D-}                               { no debug info                     }
{$R-}                               { turn off range checking           }
{$ELSE}                             { else                              }
{$D+}                               { turn on debug info                }
{$R+}                               { turn on range checking            }
{$ENDIF}                            { end conditional if                }

{_F+}                               { force far calls                   }
{_G+}                               { enable 286 instructions           }
{_N+}                               { enable coprocessor                }
{$P-}                               { no open string                    }
{$V+}                               { strict string checking            }

{-----------------------------------------------------------------------}
{ Program      : Triples                                                }
{ Last Modified: 03-23-96                                               }
{ Purpose      : To find all the pythagorean triples from 1 to 1000     }
{-----------------------------------------------------------------------}
Program PythagoreanTriples;
Uses Crt{,Timer};  { timer code at the END of this program !! }


{-----------------------------------------------------------------------}
{ global constants                                                      }
{-----------------------------------------------------------------------}
Const
      MaxNum = 1000;                { maximum number to find triple for }

{-----------------------------------------------------------------------}
{ global variables                                                      }
{-----------------------------------------------------------------------}
Var
    ICtr, ICtr2: Word;              { iteration counters                }
    Result: extended;
{-----------------------------------------------------------------------}
{ main code here                                                        }
{-----------------------------------------------------------------------}
Begin                               { begin main block                  }
  {assign(output, '');
  rewrite(output);}
  ClrScr;                           { clear the screen                  }
  {Clockon;}
  For ICtr := 1 to MaxNum Do        { go thorugh numbers                }
    For ICtr2 := ICtr to MaxNum Do  { go through numbers                }
      Begin                         { begin ICtr2 for loop              }
        Result := Sqrt(ICtr*ICtr + ICtr2 * ICtr2);
        if (Result - INT(Result) = 0)then
          Writeln({output,}ICtr,'   ', ICtr2:10,'   ', Result:6:0);
      End;                          { end ICtr2 for loop                }
  {clockoff;}
End.                                { end main block                    }
(*
-------------------------------------------------------------------------
here is the timer unit you need.

{ Timing unit for optomizing code }
unit TIMER;

interface

         procedure clockon;
         procedure clockoff;

implementation
uses dos;

var H,M,S,s100:word;
    startclock,stopclock:real;

    procedure clockon;
    begin
         gettime(h,m,s,s100);
         startclock := (H*3600)+(M*60)+S+(S100 / 100);
         Writeln('Start time = ',Startclock:0:2);
    end;
    procedure clockoff;
    begin
         gettime(h,m,s,s100);
         stopclock := (H*3600)+(M*60)+S+(S100 / 100);
         writeln;
         writeln('Stop time = ',stopclock:0:2);
         writeln('Elapsed time = ',(stopclock-startclock):0:2);
    end;

begin
end.

*)
