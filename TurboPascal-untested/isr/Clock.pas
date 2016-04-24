(*
  Category: SWAG Title: ISR HANDLING ROUTINES
  Original name: 0001.PAS
  Description: CLOCK.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{$M 2000, 0, 0}                         {  When writing TSR's you have to   }
Program Clock;                          {  use the $M directive             }
Uses Dos;

 Var
   oldint: Procedure;

Procedure Write2scr (s: String; color, x, y: Byte);
 Var
   counter1,
   counter2: Byte;
 begin                                             { In TSR's you always }
    counter1 := 2 * (x + y * 80);                  { need to use direct  }
    For counter2 := 1 to ord(s[0]) do              { screen Writes.      }
     begin                                         {                     }
      mem [$b800: counter1] := ord(s[counter2]);
      inc (counter1);
      mem [$b800: counter1] := color;
      inc (counter1);
     end;  {do}

 end;      {Write2SCR}

{$F+}                   { All Procedures will now be Far Procedures }

Procedure int_Hook; interrupt;
Var
   hour,                { Where the Hour will be stored }
   min: Word;           { "  "  " " minute "          " }
   hS,                  { Where STR Hour will be stored }
   MS: String[2];       {       STR Min                 }
begin
     hour := memW[$0000:$046e];
     min := (memW[$0000:$046c] div 18) div 60;

{ The above 2 lines of code give the hour & minute.. How?? The first
  memory location gives the hour thats easy, but the minutes are a
  little more tricky... The interrupt i'm gonna hook into is int 8
  ... it is called approximately 18.2 times/second. When its called,
  it increments 0000:046c hex. When it overflows, it inc's 0000:046e
  (which is the hour in 24 hr Format) so, dividing by 18 would give
  us the approximate second in the hour, div'ding by 60 then gives
  the hour                                                              }

     if hour > 12 then dec(hour, 12);           { Converts from 24 hr Format }
     str(min, MS);
     str(hour, HS);
     Write2scr (HS, 9, 77 - ord(hs[0]), 0);     { Writes to screen }
     Write2scr (MS, 12, 78, 0);
     Write2scr (':',10, 77, 0);
     Inline ($9c);                              { Push the flags ( you have }
     oldint;                                    { to do this beFore any int }
                                                { call like this            }
end;   {inT_HOOK}

{$F-}                                           { No more Far Procedures }

begin
  getintvec (8, @oldint);                       { Hooks the interrupt }
  setintvec (8, addr(int_hook));
  keep (0);                                     { Makes it stay resident }
end.


