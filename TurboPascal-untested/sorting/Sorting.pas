(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0047.PAS
  Description: Sorting
  Author: MIKE COPELAND
  Date: 05-25-94  08:20
*)

{
 DR> Does anyone have a good routine to sort a string array into
 DR> alphabetical order - I really only know how to do a bubble
 DR> sort, and that's a bit slow for >1000 in the array...
 DR> Preferably written in standard Pascal, as I would like to
 DR> understand it,

   Here's the conventional QuickSort (which is also included in the full
TP/BP packages as examples):
}

var T     : string;                                  { swap variable }
    GUESS : array[1..1000] of ^string;    { pointer array of strings }
procedure L_HSORT (LEFT,RIGHT : word);             { Lo-Hi QuickSort }
var LOWER,UPPER,MIDDLE : word;
    PIVOT              : string;
begin
  LOWER := LEFT; UPPER := RIGHT; MIDDLE := (LEFT+RIGHT) div 2;
  PIVOT := GUESS[MIDDLE]^;
  repeat
    while GUESS[LOWER]^ < PIVOT do Inc(LOWER);
    while PIVOT < GUESS[UPPER]^ do Dec(UPPER);
    if LOWER <= UPPER then
      begin
        T := GUESS[LOWER]^; GUESS[LOWER]^ := GUESS[UPPER]^;
        GUESS[UPPER]^ := T; Inc (LOWER); Dec (UPPER);
      end;
  until LOWER > UPPER;
  if LEFT < UPPER then L_HSORT (LEFT, UPPER);
  if LOWER < RIGHT then L_HSORT (LOWER, RIGHT)
end;                                                       { L_HSORT }

