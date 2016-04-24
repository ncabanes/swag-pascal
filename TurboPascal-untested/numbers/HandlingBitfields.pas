(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0078.PAS
  Description: Handling Bitfields
  Author: HOVIK A. MELIKIAN
  Date: 08-30-96  09:35
*)

{
Delphi Compenent Library gives a good lesson of how to do this in Turbo
Pascal, and I think it's the best way.

Let us have flags:
}

type
  TFlagValues = (flagUse, flagSets, flagInsteadOf, flagBitOperations);

Then we declare a set:

type
  TFlags = set of TFlagValues;

Variables of this type will occupy only one byte. Now, common operations:

  Flags := [];                   { clear all flags }
  Flags := Flags + flagXXX;      { set this flag to 1 }
  Include(Flags, flagXXX);       { same in TP 7.0 and Delphi, more efficient }
  Flags := Flags - flagXXX;      { clear this flag }
  Exclude(Flags, flagXXX);       { same in TP 7.0 and Delphi, more efficient }
  if flagXXX in Flags then ...   { test }

This generates same code as with bit operations and read easier.



