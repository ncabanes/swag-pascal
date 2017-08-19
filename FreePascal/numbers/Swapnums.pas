(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0022.PAS
  Description: SWAPNUMS.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
>Is there a way (using bit manipulations such as AND, OR, XOR) to
>swap to Variables without making a 3rd temporary Variable?
>

If the two Variables are numbers, and the following operations
won't overflow the limitations of the Type, then yes, you can
do it like this:
}
Var
   A, B : Integer;

begin
   A := 5;
   B := 3;
   WriteLn('A = ',a,', B = ',b);

   A := A + B;
   B := A - B;
   A := A - B;

   { which is

   A := 5 + 3 (8)
   B := 8 - 3 (5)
   A := 8 - 5 (3)

   A = 3
   B = 5 }
   
   WriteLn('A = ',a,', B = ',b);

end.
