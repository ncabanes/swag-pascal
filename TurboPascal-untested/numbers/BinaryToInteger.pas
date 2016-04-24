(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0050.PAS
  Description: Binary to Integer
  Author: SETH ANDERSON
  Date: 08-24-94  13:25
*)

{
Hey, recently, I've developed a binary to integer, and integer to binary,
conversion operations.  This is the fastest way that I know how to write this,
short of assembly (which I do not know at current).  The original code was
much longer, and much slower, yet it worked too, just slower.  If you have any
suggestions, please let me know, I'm curious to see the results.  (And, please
let me know if you find a use for this source.  Right now, I only use it in
one of several units I've written, to view binary files.)

My programming style is very organized, so it shouldn't be too hard to follow.

------------------------------ CUT HERE --------------------------------------}


TYPE
    String8 = String[8];     { For Use With The Binary Conversion }
    String16 = String[16];   { For Use With The Binary Conversion }

    Conversions = Object
        Function Bin8ToInt ( X : String ) : Integer;
        Procedure IntToBin8 ( X : Integer; VAR Binary8 : String8 );
        End;                                            { OBJECT Conversions }

{ I only use OOP because it sits in a unit.  For a normal program, or an     }
{ easy to use unit, you don't even need these three lines.  I have more      }
{ conversion subprograms added to this object, which is why I have an        }
{ individual object for the conversion subprograms.                          }

CONST
     Bits8 : Array [1..8] of Integer = (128, 64, 32, 16, 8, 4, 2, 1);

{ This defines a normal 8 bits.  I have a Bin16toInt and IntToBin16          }
{ procedure and function, retrorespectively, but I think that they do not    }
{ have any use to them.                                                      }

{────────────────────────────────────────────────────────────────────────────}

Function Conversions.Bin8ToInt ( X : String ) : Integer;

{ Purpose : Converts an 8-bit Binary "Number" to an Integer.                 }
{           The 8-bit "Number" is really an 8-character string, or at least  }
{           it should be.                                                    }

VAR
   G, Total : Integer;

Begin
     Total := 0;
     For G := 1 to 8 Do
         If ( X[G] = '1' ) then
            Total := Total + Bits8[G];
     Bin8ToInt := Total;

End;                                        { FUNCTION Conversions.Bin8ToInt }
{────────────────────────────────────────────────────────────────────────────}

Procedure Conversions.IntToBin8 ( X : Integer;
                                  VAR Binary8 : String8 );

{ Purpose : Converts an integer (from 1 to 256) to an 8-bit Binary "integer."}
{           The 8-bit "integer" is actually a string, easily convertable to  }
{           an integer.                                                      }

VAR
   G : Integer;

Begin
     Binary8 := '00000000';
     For G := 1 to 8 Do
         If ( X >= Bits8[G] ) Then
            Begin
                 X := X - Bits8[G];
                 Binary8[G] := '1';
                 End;
     If ( X > 0 ) Then
        Binary8 := 'ERROR';

End;                                       { PROCEDURE Conversions.IntToBin8 }
{────────────────────────────────────────────────────────────────────────────}

