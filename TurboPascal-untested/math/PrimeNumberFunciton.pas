(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0122.PAS
  Description: Prime Number funciton
  Author: ALLEN CHENG
  Date: 03-05-97  06:02
*)

{           Prime v1.1 (C) 1997 Allen Cheng. All Rights Reserved.

   Please feel free to use this unit on your program,
   give me Credit if you like.... Enjoy!

 This is quite fast, and is about 50-80% faster than the fastest one in SWAG.
 As this Function is optimized for large numbers, you may not see any
 differents is small numbers, but it only takes about 6 seconds to find all
 the primes from 1000000 to 1020000. A newer version will be out soon
 which should be about 10-20% faster.

Homepage:  http://www.geocities.com/SiliconValley/Park/8979/
Email:     ac@4u.net

You can always download the newest version from my Homepage.

P.S. If you've found some ways to optimized this unit, please feel free to
change anything, it's nice if you can send me a copy.
}
Unit Prime;

Interface
Function PrimeChk(Num: LongInt): Boolean;

Implementation

Function PrimeChk(Num: LongInt): Boolean;
Var x : Longint;
    y : Integer;
Begin
 x := -1; y := 0;
 Case Num Of
  2,3 : Begin PrimeChk := True; Exit; End;
  1 : Begin PrimeChk := False; Exit; End;
 End;
If (Num mod 2)=0 Then Begin PrimeChk := False; Exit; End; {Check if Even #}

While (Sqr(x) < Num) And (y < 2) Do
Begin
   x := x + 2; { Only check with Odd numbers }
   If (Num mod x)=0 Then y:=y+1;
End;
 If y <> 1 Then PrimeChk := False Else PrimeChk := True;
End;

End.

{ ------------ DEMO --------------- }

Program Example;
Uses Prime;
Var Number : LongInt;
Begin
{List all Primes from 1000000 to 1020000}
For Number := 1000000 to 1020000 Do
If PrimeChk(Number) = True Then Write(Number,' ');
End.
