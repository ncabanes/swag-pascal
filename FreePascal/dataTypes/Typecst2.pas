(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0009.PAS
  Description: TYPECST2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
 > Yes LongInts are as you say from approx -2bil to +2bil.  I'd
 > say what is happening here is that you are adding two
 > Integers & assigning the result to a LongInt.  Consider the
 > following :-
}
Var
   v1, v2   : Integer;
   v1l, v2l : LongInt;
   Res      : LongInt;

begin
     v1 := 30000;
     v2 := 30000;
     Res := v1 + v2;

{
 > This will not give Res = 60000, because as Far as I am aware
 > TP only does Type promotion to the RHE Until the actual
 > assignment operation.  What this means is that the sum of v1
 > & v1 must yield an Integer since the largest Type to contain
 > each is an Integer.  Adding two Integer 30000 numbers
 > together caUses an overflow & ends up being a random-ish
 > number, usually negative.  So what must be done here is
 > Typecasting.  This should fix it :-

 >      Res := LongInt(v1) + LongInt(v2);
}

     WriteLn(Res);
     
     v1 := 60000;
     v2 := 60000;
     Res := v1 + v2;
     WriteLn(Res);
     
     { And using longint... }
     v1l := 60000;
     v2l := 60000;
     Res := v1l + v2l;
     WriteLn(Res);
     
     Res := LongInt(v1l) + LongInt(v2l);
     WriteLn(Res);
end.
