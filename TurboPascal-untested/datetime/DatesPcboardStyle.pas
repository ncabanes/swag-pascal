(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0059.PAS
  Description: Dates -> PCBoard style
  Author: MARIO MUELLER
  Date: 08-30-96  09:35
*)

{
Does anyone happen to have the Pascal coding for a "calendar date" to "PCBoard
Julian (2-byte WORD)" conversion?

... take notice that this is not the standard 4-byte LONGINT Julian date, but
the 2-byte WORD PCBoard version of it.

I have come up with the following, however its calculations are slightly
incorrect ...

{-------------------------------------------------------------------------}
Function Cal2Word (Source : String) : Word;

{
  Title         : Cal2Word
  Purpose       : Convert Calendar MM/DD/YY Date -> PCBoard-Julian/Word
  Procs/Funcs   : [None]
  Precondition  : Source = Calendar MM/DD/YY Date
  Postcondition : Cal2Word [Function] = PCBoard-Julian/Word
}

Const {.. Declare "Cal2Word" Constants ...................................}

  Days : Array[1..12] of Word = (0,31,59,90,120,151,181,212,243,273,304,334);

Var {.. Declare "Cal2Word" Variables .....................................}

  Date  : Word;              { Calculated Julian Date }
  Year  : Word;
  Month : Word;
  Day   : Word;
  tPos  : Byte;              { String/Position Storage }

Begin

  {.. Parse Month/Day/Year from "Source"-String ..........................}

  tPos:= Pos('-',Source);

  If tPos = 0 Then Month:= 0 Else Begin
    Month:= StrInt(Copy(Source,1,tPos - 1));
    Delete(Source,1,tPos)
  End;

  tPos:= Pos('-',Source);

  If tPos = 0 Then Day:= 0 Else Begin
    Day:= StrInt(Copy(Source,1,tPos - 1));
    Delete(Source,1,tPos)
  End;

  Year:= StrInt(Source);

  {.. Actual Julian-Date Calculation .....................................}

  Date:= 36525 * Year;
  If (((Date Mod 100) = 0) and (Month < 3)) Then Dec(Date);

  Date:= (Date - (1900 * 36525)) Div 100;
  Inc(Date,Day + Days[Month]);

  Cal2Word:= Date
End;

