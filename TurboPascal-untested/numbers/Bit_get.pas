(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0003.PAS
  Description: BIT_GET.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{ You can use multiplies of 2 like: }

Function Find_Bit(B, c : Byte) : Byte;
{c is the position c=0 far right c=7 far left
returns 0 or 1}
begin
 if b MOD (b shl c) = 0 then Find_Bit := 0
  else Find_Bit := 1
end;


