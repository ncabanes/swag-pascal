(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0086.PAS
  Description: Turning Off Screen Output
  Author: JORT BLOEM
  Date: 05-26-95  23:22
*)

{
>> Well, I'm actually working on a program that uses
>> pkunzip, arj etc too, and I solved it by using another
>> page when unzipping... just change [40h:4Ah] to let's
>> say, 1, and no output should come on your screen....
}

Mem[$40:$4A]:=1;
Exec(Filename,Params); {Or whatever}
Mem[$40:$4A]:=0;


