(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0073.PAS
  Description: String Comparision
  Author: GREG ESTABROOKS
  Date: 02-03-94  09:57
*)


{*********************************************************************}
PROGRAM StrCompare;             { Jan 23/94, Greg Estabrooks.         }
USES CRT;                       { IMPORT Clrscr,WriteLn.              }
VAR
   SubName :STRING;             { Holds the Subject name entered.     }

FUNCTION StrCmp( Str1,Str2 :STRING ) :BOOLEAN;
                            { Case InSensitive Routine to compare two }
                            { strings.                                }
VAR
   StrPos   :BYTE;              { Current position within Strings.    }
   CmpResult:BOOLEAN;           { Result of comparison.               }
BEGIN
  CmpResult := TRUE;            { Initialize 'CmpResult' to TRUE.     }
  IF Length(Str1) <> Length(Str2) THEN { If not same length then don't}
    CmpResult := FALSE                 { Bother converting case and   }
                                       { compareing.                  }
  ELSE
    BEGIN
      StrPos := 0;              { Initialize 'StrPos' to 0.           }
      REPEAT                    { Loop until every char checked.      }
        INC(StrPos);            { Point to next char.                 }
        IF UpCase(Str1[StrPos]) <> UpCase(Str2[StrPos]) THEN
         BEGIN
           CmpResult := False;  { If there not the same then return   }
                                { a FALSE result.                     }
           StrPos := Length(Str2); { Now set loop exit condition.     }
         END;
      UNTIL StrPos = Length(Str2);
    END;
  StrCmp := CmpResult;
END;{StrCmp}

BEGIN
  Clrscr;                       { Clear away the screen.              }
  Write(' Name of subject ? :');{ Prompt user for subject name.       }
  Readln(SubName);              { Now get users input.                }
  IF StrCmp('English',SubName) THEN { If there the same then tell user}
    Writeln('You chose ENGLISH')
  ELSE                          { If not then ..............          }
    Writeln('Unknown Subject!',^G);{Tell user its unknown.            }
END.{StrCompare}
{*********************************************************************}
h
