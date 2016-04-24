(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0051.PAS
  Description: TV Sorting unit
  Author: BRAD WILLIAMS
  Date: 08-24-94  17:53
*)

{*******************************************************************}
{                                                                   }
{     WVS Software Company                                          }
{     Turbo Pascal Sorting Unit for TCollections                    }
{     Usage Fee: None, public domain                                }
{     Version: 1.0                                                  }
{     Release Date: 6/27/93                                         }
{                                                                   }
{     Programmer: Brad Williams                                     }
{     E-mail    : bwilliams@marvin.ag.uidaho.edu                    }
{     US Mail   : 1008 E. 7th                                       }
{                 Moscow, Idaho 83843                               }
{                                                                   }
{*******************************************************************}
{                                                                   }
{  This unit contains objects for performing various types of       }
{  sorts.  To use any of the sorting methods, simply pass them a    }
{  collection and a compare or test function.  You can write your   }
{  programs to accept a TSortProcedure/TSearchFunction as a         }
{  parameter to any function or procedure and use whichever type    }
{  of sort/search you require at that point in your program.  The   }
{  search and sort methods accept pointers to compare and test      }
{  functions so that the same functions can be used for iterative   }
{  procedures/functions in a TSortedCollection.                     }
{                                                                   }
{*******************************************************************}
UNIT TVSorts;
{****************************************************************************}
                                 INTERFACE
{****************************************************************************}
USES Objects;

TYPE
  TCompareFunction = FUNCTION (Item1, Item2 : Pointer) : Integer;
    { A TCompareFunction must return:   }
    {   1  if the Item1 > Item2         }
    {   0  if the Item1 = Item2         }
    {  -1  if the Item1 < Item2         }

  TSortProcedure = PROCEDURE  (ACollection : PCollection;
                               Compare : TCompareFunction);

  { Sort Procedures }
PROCEDURE BinaryInsertionSort (ACollection : PCollection;
                               Compare : TCompareFunction);
PROCEDURE BubbleSort (ACollection : PCollection; Compare : TCompareFunction);
PROCEDURE CombSort   (ACollection : PCollection; Compare : TCompareFunction);
PROCEDURE HeapSort   (ACollection : PCollection; Compare : TCompareFunction);
PROCEDURE QuickSort  (ACollection : PCollection; Compare : TCompareFunction);
PROCEDURE QuickSortNonRecursive (ACollection : PCollection;
                                 Compare : TCompareFunction);
PROCEDURE ShakerSort (ACollection : PCollection; Compare : TCompareFunction);
PROCEDURE ShellSort  (ACollection : PCollection; Compare : TCompareFunction);
PROCEDURE StraightInsertionSort (ACollection : PCollection;
                                 Compare : TCompareFunction);
PROCEDURE StraightSelectionSort (ACollection : PCollection;
                                 Compare : TCompareFunction);
PROCEDURE TreeSort (ACollection : PCollection; Compare : TCompareFunction);


  { Compare Procedures - Must write your own Compare for pointer variables. }
  { This allows one sort routine to be used on any array.                   }
FUNCTION  CompareChars    (Item1, Item2 : Pointer) : Integer; FAR;
FUNCTION  CompareInts     (Item1, Item2 : Pointer) : Integer; FAR;
FUNCTION  CompareLongInts (Item1, Item2 : Pointer) : Integer; FAR;
FUNCTION  CompareReals    (Item1, Item2 : Pointer) : Integer; FAR;
FUNCTION  CompareStrs     (Item1, Item2 : Pointer) : Integer; FAR;

{****************************************************************************}
                               IMPLEMENTATION
{****************************************************************************}
{                                                                            }
{                      Local Procedures and Functions                        }
{                                                                            }
{****************************************************************************}
PROCEDURE Swap (ACollection : PCollection; A, B : Integer);
VAR Item : Pointer;
BEGIN
  Item := ACollection^.At(A);
  ACollection^.AtPut(A,ACollection^.At(B));
  ACollection^.AtPut(B,Item);
END;
{****************************************************************************}
{                                                                            }
{                      Global Procedures and Functions                       }
{                                                                            }
{****************************************************************************}
PROCEDURE BinaryInsertionSort (ACollection : PCollection;
                               Compare : TCompareFunction);
VAR i, j, Middle, Left, Right : LongInt;
BEGIN
  FOR i := 0 TO (ACollection^.Count - 1) DO
      BEGIN
        Left := 0;
        Right := i;
        WHILE Left < Right DO
          BEGIN
            Middle := (Left + Right) DIV 2;
            WITH ACollection^ DO
              IF Compare(At(Middle),At(i)) < 1
                 THEN Left := Middle + 1
                 ELSE Right := Middle;
          END;
        FOR j := i DOWNTO (Right + 1) DO
            Swap(ACollection,j,j-1);
      END;
END;
{****************************************************************************}
PROCEDURE BubbleSort (ACollection : PCollection; Compare : TCompareFunction);
VAR i, j : Integer;
BEGIN
  WITH ACollection^ DO
    FOR i := 1 TO (Count - 1) DO
        FOR j := (Count - 1) DOWNTO i DO
        IF Compare(At(j-1),At(j)) = 1
           THEN Swap(ACollection,j,j-1);
END;
{****************************************************************************}
PROCEDURE CombSort (ACollection : PCollection; Compare : TCompareFunction);
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
  Gap := Round((ACollection^.Count-1)/ShrinkFactor);
  WITH ACollection^ DO
    REPEAT
      Finished := TRUE;
      Gap := Trunc(Gap/ShrinkFactor);
      IF Gap < 1
         THEN Gap := 1
         ELSE IF ((Gap = 9) OR (Gap = 10))
                 THEN Gap := 11;
      FOR i := 0 TO ((Count - 1) - Gap) DO
          IF Compare(At(i),At(i+Gap)) = 1
             THEN BEGIN
                    Swap(ACollection,i,i+gap);
                    Finished := False;
                  END;
  UNTIL ((Gap = 1) AND Finished);
END;
{****************************************************************************}
PROCEDURE HeapSort (ACollection : PCollection; Compare : TCompareFunction);
  { Performs best when items are in inverse order. }
VAR L, R : LongInt;
    X : Pointer;
    {*****************************************}
    PROCEDURE Sift;
    VAR i, j : LongInt;
        Label 13;
    BEGIN
      i := L;
      j := 2 * i;
      X := ACollection^.At(i);
      WITH ACollection^ DO
        WHILE j <= R DO
          BEGIN
            IF j < R
               THEN IF Compare(At(j),At(j+1)) = -1
                       THEN Inc(j);
            IF Compare(X,At(j)) >= 0
               THEN GoTo 13;
            AtPut(i,At(j));
            i := j;
            j := 2 * i;
          END;
      13: ACollection^.AtPut(i,X);
    END;
    {*****************************************}
BEGIN
  L := ((ACollection^.Count - 1) DIV 2) + 1;
  R := ACollection^.Count - 1;
  WHILE L > 0 DO
    BEGIN
      Dec(L);
      Sift;
    END;
  WHILE R > 0 DO
    BEGIN
      X := ACollection^.At(1);
      Swap(ACollection,0,R);
      Dec(R);
      Sift;
    END;
END;
{****************************************************************************}
PROCEDURE QuickSort (ACollection : PCollection; Compare : TCompareFunction);
  {****************************************************************}
  PROCEDURE Sort (Left, Right : LongInt);
  VAR i, j  : LongInt;
      X : Pointer;
  BEGIN
    WITH ACollection^ DO
      BEGIN
        i := Left;
        j := Right;
        X := At((Left + Right) DIV 2);
        REPEAT
          WHILE Compare(At(i),X) = -1 DO Inc(i);
          WHILE Compare(X,At(j)) = -1 DO Dec(j);
          IF i <= j
             THEN BEGIN
                    Swap(ACollection,i,j);
                    Inc(i);
                    Dec(j)
                END;
        UNTIL i > j;
        IF Left < j
           THEN Sort(Left,j);
        IF i < Right
           THEN Sort(i,Right)
      END;
  END;
  {****************************************************************}
BEGIN
  Sort(0,ACollection^.Count-1);
END;
{****************************************************************************}
PROCEDURE QuickSortNonRecursive (ACollection : PCollection;
                                 Compare : TCompareFunction);
CONST m = 12;
VAR i, j, L, R : LongInt;
    x : Pointer;
    s : 0..m;
    Stack : ARRAY[1..m] OF RECORD
                             l, r : LongInt;
                           END;
BEGIN
  s := 1;
  Stack[1].l := 0;
  Stack[1].r := ACollection^.Count - 1;
  WITH ACollection^ DO
    REPEAT
      L := Stack[s].l;
      R := Stack[s].r;
      Dec(S);
      REPEAT
        i := L;
        j := R;
        x := At((L + R) DIV 2);
        REPEAT
          WHILE Compare(x,At(i)) =  1 DO Inc(i);
          WHILE Compare(x,At(j)) = -1 DO Dec(j);
          IF i <= j
             THEN BEGIN
                    Swap(ACollection,i,j);
                    Inc(i);
                    Dec(j);
                  END;
        UNTIL i > j;
        IF i < R
           THEN BEGIN
                  Inc(s);
                  Stack[s].l := i;
                  Stack[s].r := R;
                END;
        R := j;
      UNTIL L >= R;
    UNTIL s = 0;
END;
{****************************************************************************}
PROCEDURE ShakerSort (ACollection : PCollection; Compare : TCompareFunction);
  { Works for any array and any index range. }
VAR j, k, Left, Right : LongInt;
BEGIN
  Left := 1;
  Right := (ACollection^.Count - 1);
  k := Right;
  WITH ACollection^ DO
    REPEAT
      FOR j := Right DOWNTO Left DO
          IF Compare(At(j-1),At(j)) = 1
             THEN BEGIN
                    Swap(ACollection,j,j-1);
                    k := j;
                  END;
      Left := k + 1;
      FOR j := Left TO Right DO
          IF Compare(At(j-1),At(j)) = 1
             THEN BEGIN
                    Swap(ACollection,j,j-1);
                    k := j;
                  END;
      Right := k - 1;
    UNTIL Left > Right;
END;
{****************************************************************************}
PROCEDURE ShellSort (ACollection : PCollection; Compare : TCompareFunction);
VAR Gap, i, j, k : LongInt;
BEGIN
  Gap := (ACollection^.Count - 1) DIV 2;
  WHILE (Gap > 0) DO
    BEGIN
      FOR i := Gap TO (ACollection^.Count - 1) DO
          BEGIN
            j := i - Gap;
            WHILE (j > -1) DO
              BEGIN
                k := j + Gap;
                IF Compare(ACollection^.At(j),ACollection^.At(k)) < 1
                   THEN j := 0
                   ELSE Swap(ACollection,j,k);
                Dec(j,Gap);
              END;
          END;
      Gap := Gap DIV 2;
    END;
END;
{****************************************************************************}
PROCEDURE StraightInsertionSort (ACollection : PCollection;
                                 Compare : TCompareFunction);
VAR i, j : LongInt;
    X : Pointer;
BEGIN
  WITH ACollection^ DO
    FOR i := 0 TO (Count - 1) DO
      BEGIN
        X := At(i);
        j := i;
        WHILE (j > 0) AND (Compare(X,At(j-1)) = -1) DO
          BEGIN
            AtPut(j,At(j-1));
            Dec(j);
          END;
        AtPut(j,X);
      END;
END;
{****************************************************************************}
PROCEDURE StraightSelectionSort (ACollection : PCollection;
                                 Compare : TCompareFunction);
VAR i, j, k  : LongInt;
BEGIN
  FOR i := 0 TO (ACollection^.Count - 1) DO
      BEGIN
        k := i;
        FOR j := (i + 1) TO (ACollection^.Count - 1) DO
            IF Compare(ACollection^.At(j),ACollection^.At(k)) = -1
               THEN k := j;
        Swap(ACollection,i,k);
      END;
END;
{****************************************************************************}
PROCEDURE TreeSort (ACollection : PCollection; Compare : TCompareFunction);
{after D.Cooke, A.H.Craven, G.M.Clarke: Statistical Computing
 in Pascal, Publisher: Edward Arnold, London 1985 ISBN 0-7131-3545-X }
TYPE PNode    = ^Node;
     Node = RECORD
              Value : Pointer;
              Left  : PNode;
              Right : PNode;
            END;
VAR  Add, Top : PNode;
     i    : LongInt;
    {***********************************************************}
    PROCEDURE MakeTree (VAR Node : PNode);
    BEGIN
      IF Node = NIL
         THEN Node := Add
         ELSE IF Compare(Add^.Value,Node^.Value) = 1
                 THEN MakeTree(Node^.Right)
                 ELSE MakeTree(Node^.Left);
    END;
    {**********************************************************}
     PROCEDURE StripTree (Node : PNode);
     BEGIN
       IF Node <> NIL
          THEN BEGIN
                 StripTree(Node^.Left);
                 ACollection^.AtPut(i,Node^.Value);
                 Inc(i);
                 StripTree(Node^.Right)
               END;
     END;
    {**********************************************************}
BEGIN
  Top := NIL;
  FOR i := 0 TO (ACollection^.Count - 1) DO
    BEGIN
      New(Add);
      Add^.Value := ACollection^.At(i);
      Add^.Left  := NIL;
      Add^.Right := NIL;
      MakeTree(Top)
    END;
    i := 0;
    StripTree(Top)
END;
{****************************************************************************}
{                                                                            }
{                            Compare Procedures                              }
{                                                                            }
{****************************************************************************}
FUNCTION CompareChars (Item1, Item2 : Pointer) : Integer;
BEGIN
  IF Char(Item1^) < Char(Item2^)
     THEN CompareChars := -1
     ELSE CompareChars := Ord(Char(Item1^) <> Char(Item2^));
END;
{*****************************************************************************}
FUNCTION CompareInts (Item1, Item2 : Pointer) : Integer;
BEGIN
  IF Integer(Item1^) < Integer(Item2^)
     THEN CompareInts := -1
     ELSE CompareInts := Ord(Integer(Item1^) <> Integer(Item2^));
END;
{*****************************************************************************}
FUNCTION CompareLongInts (Item1, Item2 : Pointer) : Integer;
BEGIN
  IF LongInt(Item1^) < LongInt(Item2^)
     THEN CompareLongInts := -1
     ELSE CompareLongInts := Ord(LongInt(Item1^) <> LongInt(Item2^));
END;
{*****************************************************************************}
FUNCTION CompareReals (Item1, Item2 : Pointer) : Integer;
BEGIN
  IF Real(Item1^) < Real(Item2^)
     THEN CompareReals := -1
     ELSE CompareReals := Ord(Real(Item1^) <> Real(Item2^));
END;
{*****************************************************************************}
FUNCTION CompareStrs (Item1, Item2 : Pointer) : Integer;
BEGIN
  IF String(Item1^) < String(Item2^)
     THEN CompareStrs := -1
     ELSE CompareStrs := Ord(String(Item1^) <> String(Item2^));
END;
{*****************************************************************************}
BEGIN
END.

{ -----------------------------------  DEMO PROGRAM ---------------------}

PROGRAM Test;
USES Crt, Objects, TVSorts;

CONST
  MaxCollectionSize = 10;

VAR C : TCollection;
    i, j, k : Integer;
    Ch : ^Char;

BEGIN
  Randomize;
  FOR i := 1 TO 11 DO
    BEGIN
        { initialize collection and load with data in reverse order }
      C.Init(MaxCollectionSize,1);
      FOR j := MaxCollectionSize DOWNTO 0 DO
          BEGIN
            k := Random(255);
            WHILE (k < 65) OR (k > 90) DO k := Random(255);
            New(Ch);
            Ch^ := Char(k);
            C.AtInsert(0,Ch);
          END;
        { display unsorted data }
      ClrScr;
      CASE i OF
        1 : WriteLn('Binary Insertion Sort');
        2 : WriteLn('Bubble Sort');
        3 : WriteLn('Comb Sort');
        4 : WriteLn('Heap Sort');
        5 : WriteLn('Quick Sort');
        6 : WriteLn('Non-recursive Quick Sort');
        7 : WriteLn('Shaker Sort');
        8 : WriteLn('Shell Sort');
        9 : WriteLn('Straight Insertion Sort');
       10 : WriteLn('Straight Selection Sort');
       11 : WriteLn('Tree Sort');
      END;
      FOR j := 0 TO (C.Count - 1) DO Write(Char(C.At(j)^):2);
        { sort data }
      CASE i OF
        1 : BinaryInsertionSort(@C,CompareChars);
        2 : BubbleSort(@C,CompareChars);
        3 : CombSort(@C,CompareChars);
        4 : HeapSort(@C,CompareChars);
        5 : QuickSort(@C,CompareChars);
        6 : QuickSortNonRecursive(@C,CompareChars);
        7 : ShakerSort(@C,CompareChars);
        8 : ShellSort(@C,CompareChars);
        9 : StraightInsertionSort(@C,CompareChars);
       10 : StraightSelectionSort(@C,CompareChars);
       11 : TreeSort(@C,CompareChars);
      END;
        { display sorted data }
      WriteLn;
      FOR j := 0 TO (C.Count - 1) DO Write(Char(C.At(j)^):2);
      ReadLn;
        { clear of collection }
    END;
END.
