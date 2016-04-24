(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0042.PAS
  Description: Complete Sorting Unit
  Author: SWAG SUPPORT GROUP
  Date: 11-26-93  17:46
*)

UNIT Sort;

  { These sort routines are for arrays of Integers.  Count is the maximum }
  { number of items in the array.                                         }

{****************************************************************************}
                             INTERFACE
{****************************************************************************}
FUNCTION  BinarySearch (VAR A; X : Integer; Count : Integer) : Integer;
PROCEDURE BubbleSort (VAR A; Count : Integer); {slow}
PROCEDURE CombSort (VAR A; Count : Integer);
PROCEDURE QuickSort (VAR A; Count : Integer);  {fast}
FUNCTION  SequentialSearch (VAR A; X : Integer; Count : Integer) : Integer;
PROCEDURE ShellSort (VAR A; Count : Integer);  {moderate}
{****************************************************************************}
                             IMPLEMENTATION
{****************************************************************************}
TYPE
  SortArray = ARRAY[0..0] OF Integer;
{****************************************************************************}
{                                                                            }
{                   Local Procedures and Functions                           }
{                                                                            }
{****************************************************************************}
PROCEDURE Swap (VAR A, B : Integer);
VAR C : Integer;
BEGIN
   C := A;
   A := B;
   B := C;
END;
{****************************************************************************}
{                                                                            }
{                   Global Procedures and Functions                          }
{                                                                            }
{****************************************************************************}
FUNCTION BinarySearch (VAR A; X : Integer; Count : Integer) : Integer;
VAR High, Low, Mid : Integer;
BEGIN
  Low := 1;
  High := Count;
      WHILE High >= Low DO
         BEGIN
            Mid := Trunc(High + Low) DIV 2;
            IF X > SortArray(A)[mid]
               THEN Low := Mid + 1
               ELSE IF X < SortArray(A)[Mid]
                       THEN High := Mid - 1
                       ELSE High := -1;
         END;
      IF High = -1
         THEN BinarySearch := Mid
         ELSE BinarySearch := 0;
   END;
{****************************************************************************}
PROCEDURE BubbleSort (VAR A; Count : Integer);
VAR i, j : Integer;
BEGIN
   FOR i := 2 TO Count DO
     FOR j := Count DOWNTO i DO
       IF SortArray(A)[j-1] > SortArray(A)[j]
          THEN Swap(SortArray(A)[j],SortArray(A)[j-1]);
END;
{****************************************************************************}
PROCEDURE CombSort (VAR A; Count : Integer);
  { The combsort is an optimised version of the bubble sort. It uses a     }
  { decreasing gap in order to compare values of more than one element     }
  { apart.  By decreasing the gap the array is gradually "combed" into     }
  { order ... like combing your hair. First you get rid of the large       }
  { tangles, then the smaller ones ...                                     }
  { There are a few particular things about the combsort.                  }
  { Firstly, the optimal shrink factor is 1.3 (worked out through a        }
  { process of exhaustion by the guys at BYTE magazine). Secondly, by      }
  { never having a gap of 9 or 10, but always using 11, the sort is        }
  { faster.                                                                }
  { This sort approximates an n log n sort - it's faster than any other    }
  { sort I've seen except the quicksort (and it beats that too sometimes). }
  { The combsort does not slow down under *any* circumstances. In fact, on }
  { partially sorted lists (including *reverse* sorted lists) it speeds up.}
CONST ShrinkFactor = 1.3;  { Optimal shrink factor ...       }
VAR
  Gap, i, Temp : Integer;
  Finished : Boolean;
BEGIN
  Gap := Trunc(ShrinkFactor);
  REPEAT
    Finished := TRUE;
    Gap := Trunc(Gap/ShrinkFactor);
    IF Gap < 1
       THEN { Gap must *never* be less than 1 } Gap := 1
       ELSE IF Gap IN [9,10]
               THEN { Optimises the sort ... } Gap := 11;
    FOR i := 1 TO (Count - Gap) DO
      IF SortArray(A)[i] < SortArray(A)[i+gap]
         THEN BEGIN
                Swap(SortArray(A)[i],SortArray(A)[i + Gap]);
                Finished := FALSE;
              END;
  UNTIL (Gap = 1) AND Finished;
END;
{****************************************************************************}
PROCEDURE QuickSort (VAR A; Count : Integer);
  {**************************************************************************}
  PROCEDURE PartialSort(LowerBoundary, UpperBoundary : Integer; VAR A);
  VAR ii, l1, r1, i, j, k : Integer;
  BEGIN
    k := (SortArray(A)[LowerBoundary] + SortArray(A)[UpperBoundary]) DIV 2;
    i := LowerBoundary;
    j := UpperBoundary;
    REPEAT
      WHILE SortArray(A)[i] < k DO Inc(i);
      WHILE k < SortArray(A)[j] DO Dec(j);
      IF i <= j
         THEN BEGIN
                Swap(SortArray(A)[i],SortArray(A)[j]);
                Inc(i);
                Dec(j);
              END;
    UNTIL i > j;
    IF LowerBoundary < j
       THEN PartialSort(LowerBoundary,j,A);
    IF i < UpperBoundary
       THEN PartialSort(UpperBoundary,i,A);
  END;
  {*************************************************************************}
BEGIN
  PartialSort(1,Count,A);
END;
{****************************************************************************}
FUNCTION SequentialSearch (VAR A; X : Integer; Count : Integer) : Integer;
VAR i : Integer;
BEGIN
  FOR i := 1 TO Count DO
    IF X = Sortarray(A)[i]
       THEN BEGIN
              SequentialSearch := i;
              Exit;
            END;
  SequentialSearch := 0;
END;
{****************************************************************************}
PROCEDURE ShellSort (VAR A; Count : Integer);
VAR Gap, i, j, k : Integer;
BEGIN
  Gap := Count DIV 2;
  WHILE (gap > 0) DO
    BEGIN
      FOR i := (Gap + 1) TO Count DO
        BEGIN
          j := i - Gap;
          WHILE (j > 0) DO
            BEGIN
              k := j + gap;
              IF (SortArray(A)[j] <= SortArray(A)[k])
                 THEN j := 0
                 ELSE Swap(SortArray(A)[j],SortArray(A)[k]);
              j := j - Gap;
            END;
        END;
      Gap := Gap DIV 2;
    END;
END;
{*****************************************************************************}
END.

