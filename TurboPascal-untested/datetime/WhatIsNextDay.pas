(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0026.PAS
  Description: What is NEXT day ??
  Author: ANDREW KEY
  Date: 10-28-93  11:34
*)

{===========================================================================
Date: 10-04-93 (12:39)
From: ANDREW KEY
Subj: What is NEXT day ??
---------------------------------------------------------------------------
 AC> My assignment is to write a program, given three integers whose values
 AC> represent a day between January 1, 1900 and December 30, 1999, will
 AC> output the value representing the day following.

 AC> I am running into problems with three things.  The end of a month, the
 AC> end of a year, and leap years.

Here's a procedure you might get some ideas from... }

procedure NextDay(var MM,DD,YYYY: integer);
  const
    DaysInMonth: array[0..1,1..12] of integer =
      ((31,28,31,30,31,30,31,31,30,31,30,31),   {regular year}
       (31,29,31,30,31,30,31,31,30,31,30,31));  {leap year}
  var
    Leap: integer;
  begin
    Inc(DD);                            {increment day}
    if (YYYY mod 4) = 0 then            {is it a leap year?}
      Leap:=1                           {Leap year}
    else
      Leap:=0;                          {non-leap year}
    if DD>DaysInMonth[Leap,MM] then     {is DD > the end of the month?}
      begin
        DD:=1;                          {set to 1st of month}
        Inc(MM);                        {increment month by one}
        if MM>12 then                   {is MM > December?}
          begin
            MM:=1;                      {set MM to January}
            Inc(YYYY);                  {and increment YYYY}
          end; {if MM>12}
      end; {if DD>Days}
  end; {proc NextDay}


