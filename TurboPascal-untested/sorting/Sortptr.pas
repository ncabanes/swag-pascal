(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0028.PAS
  Description: SORT-PTR.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
   This is using the concept of a PoINter Array (an Array of PoINters).  It
allows For a _very_ large amount of data, sINce you allocate each Record space
of the Heap.  You must allocate each space For each Record as you create the
Record:
}

  New (INFOSTUFF[3]);  { allocates space For 3rd Record }
  With INFOSTUFF[6]^ do  { works With 6th Record }
    begin
      NAME := 'Patrick Edwards'; IDNUM := 60000; MOM := ''
    end;

   The sort could be:

Var T : INFO;
Procedure L_HSorT (LEFT,RIGHT : Word);      { Lo-Hi QuickSort }
Var LOWER,UPPER,MIDDLE : Word;
    PIVOT              : INFO;
begin
  LOWER := LEFT; UPPER := RIGHT; MIDDLE := (LEFT+RIGHT) div 2;
  PIVOT := INFOSTUFF[MIDDLE]^;
  Repeat
    While INFOSTUFF[LOWER]^.NAME < PIVOT.NAME do INc(LOWER);
    While PIVOT.NAME < INFOSTUFF[UPPER]^.NAME do Dec(UPPER);
    if LOWER <= UPPER then
      begin
        T := INFOSTUFF[LOWER]^; INFOSTUFF[LOWER]^ := INFOSTUFF[UPPER]^;
        INFOSTUFF[UPPER]^ := T;
        INc (LOWER); Dec (UPPER);
      end;
  Until LOWER > UPPER;
  if LEFT < UPPER then L_HSorT (LEFT, UPPER);
  if LOWER < RIGHT then L_HSorT (LOWER, RIGHT);
end;                                                { L_HSorT }

{   called as:

L_HSorT (1,10);
}

