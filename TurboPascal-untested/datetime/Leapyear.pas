(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0013.PAS
  Description: LEAPYEAR.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
> I'm doing some date routines and I need to know if it is a leap year to
> validate a date..   A leap year is evenly divisble by 4..  I have no
> idea how to check to see if a remainder is present..  I'm going to try
> to read my manauls and stuff... but I'd appreciate any help!  Thanks!
}

  LeapYear := Byte((Year mod 4 = 0) and (Month = 2));

  if LeapYear = 1 then
    if Byte((Year mod 100 = 0) and (Year mod 400 <> 0)) = 1 then
      LeapYear := 0;


