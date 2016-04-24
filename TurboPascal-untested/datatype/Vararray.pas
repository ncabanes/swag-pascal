(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0012.PAS
  Description: VARARRAY.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
>   I'm trying to figure out a way to declair a Variable, such as an
>   Array, and I don't know the size Until I've loaded the Program.
>   I've tried stuff like........
>
>   Type
>       Buf : Array[1..1000] of Char;
>   Var
>       Buffer : ^Buf
>   begin
>     Getmem(Buffer,xxx)


Here's how:
}

{$R-} { <-- essential For this trick }

Type
  tFlexArray = Array[1..1] of Integer;

Var
  pFlexArray : ^tFlexArray;
  NumofElements,i : Integer;

begin
  Write('How many elements do you want in the Array?  ');
  readln(NumofElements);
  getmem(pFlexArray, (NumofElements * sizeof(Integer)));
  For i := 1 to NumofElements do
    pFlexArray^[i] := i;

  Write('Test which element?  (Will contain same value as index)  ');
  readln(i);
  Writeln('Element ',i,' contains ',pFlexArray^[i]);
end.

