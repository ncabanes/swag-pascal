Unit SORTER;

INTERFACE

TYPE
  PtrArray     = ARRAY[1..1] OF Pointer;

  TCompareFunction = FUNCTION (VAR AnArray; Item1, Item2 : LongInt) : Integer;
    { A TCompareFunction must return:   }
    {   1  if the Item1 > Item2         }
    {   0  if the Item1 = Item2         }
    {  -1  if the Item1 < Item2         }

  TSwapProcedure  = PROCEDURE (VAR AnArray; Item1, Item2 : LongInt);


PROCEDURE CombSort (VAR AnArray; Min, Max : LongInt;
                    Compare : TCompareFunction; Swap : TSwapProcedure);

  { Compare Procedures - Must write your own Compare for pointer variables. }
  { This allows one sort routine to be used on any array.                   }
FUNCTION  CompareChars    (VAR AnArray; Item1, Item2 : LongInt) : Integer;
                           FAR;
FUNCTION  CompareInts     (VAR AnArray; Item1, Item2 : LongInt) : Integer;
                           FAR;
FUNCTION  CompareLongInts (VAR AnArray; Item1, Item2 : LongInt) : Integer;
                           FAR;
FUNCTION  CompareReals    (VAR AnArray; Item1, Item2 : LongInt) : Integer;
                           FAR;
FUNCTION  CompareStrs     (VAR AnArray; Item1, Item2 : LongInt) : Integer;
                           FAR;

  { Swap procedures to be used in any sorting routine.  }
  { This allows one sorting routine to be on any array. }
PROCEDURE SwapChars    (VAR AnArray; A, B : LongInt); FAR;
PROCEDURE SwapInts     (VAR AnArray; A, B : LongInt); FAR;
PROCEDURE SwapLongInts (VAR AnArray; A, B : LongInt); FAR;
PROCEDURE SwapPtrs     (VAR AnArray; A, B : LongInt); FAR;
PROCEDURE SwapReals    (VAR AnArray; A, B : LongInt); FAR;
PROCEDURE SwapStrs     (VAR AnArray; A, B : LongInt); FAR;
{****************************************************************************}
                               IMPLEMENTATION
{****************************************************************************}
TYPE
  CharArray    = ARRAY[1..1] OF Char;
  IntArray     = ARRAY[1..1] OF Integer;
  LongIntArray = ARRAY[1..1] OF LongInt;
  RealArray    = ARRAY[1..1] OF Real;
  StrArray     = ARRAY[1..1] OF String;

{****************************************************************************}
{                                                                            }
{                      Local Procedures and Functions                        }
{                                                                            }
{****************************************************************************}
PROCEDURE AdjustArrayIndexes (VAR Min, Max : LongInt);
  { Adjusts array indexes to a one-based array. }
VAR Fudge : LongInt;
BEGIN
  Fudge := 1 - Min;
  Inc(Min,Fudge);
  Inc(Max,Fudge);
END;
{****************************************************************************}
{                                                                            }
{                      Global Procedures and Functions                       }
{                                                                            }
{****************************************************************************
}PROCEDURE CombSort (VAR AnArray; Min, Max : LongInt;
                    Compare : TCompareFunction; Swap : TSwapProcedure);
  { The combsort is an optimised version of the bubble sort. It uses a }
  { decreasing gap in order to compare values of more than one element }
  { apart.  By decreasing the gap the array is gradually "combed" into }
  { order ... like combing your hair. First you get rid of the large   }
  { tangles, then the smaller ones ...                                 }
  {                                                                    }
  { There are a few particular things about the combsort. Firstly, the }
  { optimal shrink factor is 1.3 (worked out through a process of      }
  { exhaustion by the guys at BYTE magazine). Secondly, by never       }
  { having a gap of 9 or 10, but always using 11, the sort is faster.  }
  {                                                                    }
  { This sort approximates an n log n sort - it's faster than any      }
  { other sort I've seen except the quicksort (and it beats that too   }
  { sometimes ... have you ever seen a quicksort become an (n-1)^2     }
  { sort ... ?). The combsort does not slow down under *any*           }
  { circumstances. In fact, on partially sorted lists (including       }
  { *reverse* sorted lists) it speeds up.                              }
  {                                                                    }
  { More information in the April 1991 BYTE magazine.                  }
CONST ShrinkFactor = 1.3;
VAR Gap, i   : LongInt;
    Finished : Boolean;
BEGIN
  AdjustArrayIndexes(Min,Max);
  Gap := Round(Max/ShrinkFactor);
  REPEAT
    Finished := TRUE;
    Gap := Trunc(Gap/ShrinkFactor);
    IF Gap < 1
       THEN Gap := 1
       ELSE IF (Gap = 9) OR (Gap = 10)
               THEN Gap := 11;
    FOR i := Min TO (Max - Gap) DO
        IF Compare(AnArray,i,i+Gap) = 1
           THEN BEGIN
                  Swap(AnArray,i,i+Gap);
                  Finished := False;
                END;
  UNTIL ((Gap = 1) AND Finished);
END;
{****************************************************************************
}{                                                                           
 }{                            Compare
Procedures                              }{                                   
                                         }{**********************************
******************************************}FUNCTION CompareChars (VAR 
AnArray; Item1, Item2 : LongInt) : Integer;BEGIN
  IF CharArray(AnArray)[Item1] < CharArray(AnArray)[Item2]
     THEN CompareChars := -1
     ELSE IF CharArray(AnArray)[Item1] = CharArray(AnArray)[Item2]
             THEN CompareChars := 0
             ELSE CompareChars := 1;
END;
{*****************************************************************************}
FUNCTION CompareInts (VAR AnArray; Item1, Item2 : LongInt) : Integer;
BEGIN
  IF IntArray(AnArray)[Item1] < IntArray(AnArray)[Item2]
     THEN CompareInts := -1
     ELSE IF IntArray(AnArray)[Item1] = IntArray(AnArray)[Item2]
             THEN CompareInts := 0
             ELSE CompareInts := 1;
END;
{*****************************************************************************}
FUNCTION CompareLongInts (VAR AnArray; Item1, Item2 : LongInt) : Integer;
BEGIN
  IF LongIntArray(AnArray)[Item1] < LongIntArray(AnArray)[Item2]
     THEN CompareLongInts := -1
     ELSE IF LongIntArray(AnArray)[Item1] = LongIntArray(AnArray)[Item2]
             THEN CompareLongInts := 0
             ELSE CompareLongInts := 1;
END;
{*****************************************************************************}
FUNCTION CompareReals (VAR AnArray; Item1, Item2 : LongInt) : Integer;
BEGIN
  IF RealArray(AnArray)[Item1] < RealArray(AnArray)[Item2]
     THEN CompareReals := -1
     ELSE IF RealArray(AnArray)[Item1] = RealArray(AnArray)[Item2]
             THEN CompareReals := 0
             ELSE CompareReals := 1;
END;
{*****************************************************************************}
FUNCTION CompareStrs (VAR AnArray; Item1, Item2 : LongInt) : Integer;
BEGIN
  IF StrArray(AnArray)[Item1] < StrArray(AnArray)[Item2]
     THEN CompareStrs := -1
     ELSE IF StrArray(AnArray)[Item1] = StrArray(AnArray)[Item2]
             THEN CompareStrs := 0
             ELSE CompareStrs := 1;
END;
{****************************************************************************}
{                                                                            }
{                             Move Procedures                                }
{                                                                            }
{****************************************************************************}
PROCEDURE MoveChar (VAR AnArray; Item : LongInt; VAR Hold);
BEGIN
  Char(Hold) := CharArray(AnArray)[Item];
END;
{****************************************************************************}
{                                                                            }
{                           MoveBack Procedures                              }
{                                                                            }
{****************************************************************************}
PROCEDURE MoveBackChar (VAR AnArray; Item : LongInt; VAR Hold);
BEGIN
  CharArray(AnArray)[Item] := Char(Hold);
END;
{****************************************************************************}
{                                                                            }
{                             Swap Procedures                                }
{                                                                            }
{****************************************************************************}
PROCEDURE SwapChars (VAR AnArray; A, B : LongInt);
VAR Item : Char;
BEGIN
  Item := CharArray(AnArray)[A];
  CharArray(AnArray)[A] := CharArray(AnArray)[B];
  CharArray(AnArray)[B] := Item;
END;
{*****************************************************************************}
PROCEDURE SwapInts (VAR AnArray; A, B : LongInt);
VAR Item : Integer;
BEGIN
  Item := IntArray(AnArray)[A];
  IntArray(AnArray)[A] := IntArray(AnArray)[B];
  IntArray(AnArray)[B] := Item;
END;
{*****************************************************************************}
PROCEDURE SwapLongInts (VAR AnArray; A, B : LongInt);
VAR Item : LongInt;
BEGIN
  Item := LongIntArray(AnArray)[A];
  LongIntArray(AnArray)[A] := LongIntArray(AnArray)[B];
  LongIntArray(AnArray)[B] := Item;
END;
{****************************************************************************}
PROCEDURE SwapPtrs (VAR AnArray; A, B : LongInt);
VAR Item : Pointer;
BEGIN
  Item := PtrArray(AnArray)[A];
  PtrArray(AnArray)[A] := PtrArray(AnArray)[B];
  PtrArray(AnArray)[B] := Item;
END;
{****************************************************************************}
PROCEDURE SwapReals (VAR AnArray; A, B : LongInt);
VAR Item : Real;
BEGIN
  Item := RealArray(AnArray)[A];
  RealArray(AnArray)[A] := RealArray(AnArray)[B];
  RealArray(AnArray)[B] := Item;
END;
{*****************************************************************************}
PROCEDURE SwapStrs (VAR AnArray; A, B : LongInt);
VAR Item : String;
BEGIN
  Item := StrArray(AnArray)[A];
  StrArray(AnArray)[A] := StrArray(AnArray)[B];
  StrArray(AnArray)[B] := Item;
END;
{*****************************************************************************}
BEGIN
END.
