(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0035.PAS
  Description: Change Number Base
  Author: JOHN GUILLORY
  Date: 11-02-93  05:08
*)

{ Updated NUMBERS.SWG on November 2, 1993 }

{
JOHN GUILLORY

> Can someone please show me how I would convert a base 10 number to base 36?
}

Function BaseChange(Num, NewBase : Word) : String;
Const
  BaseChars : Array [0..36] of Char = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
Var
  St : String;
begin
  St := '';
  Repeat
    St  := BaseChars[Num MOD NewBase] + St;
    Num := Num Div NewBase;
  Until Num = 0;
  BaseChange := St;
end;

{
This will convert a number in Base10 (Stored in Orig) to any Base in the
range of 2 through 36 (Please, no base-1's/0's)
}

begin
  Writeln(Basechange(33, 3));
end.
