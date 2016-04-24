(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0050.PAS
  Description: Alphabetical Order
  Author: CHRISTIAN TIBERG
  Date: 08-24-94  13:58
*)


{ This unit will sort ANY type of data into ANY type of order. As an added
bonus, there are a routine to search through a sorted list of ANY type...
Credits go to Björn Felten for his QSort unit, which inspired me to write this
routine }

Unit SortSrch;

interface

Type
    CompFunc = Function(Item1, Item2: Integer): Integer;
    SwapProc = Procedure(Item1, Item2: Integer);
    CompOneFunc = Function(Item: Integer): Integer;

Procedure QuickSort(First, Last: Integer; Comp: CompFunc; Swap: SwapProc);
Function BinarySearch(First, Last: Integer; CompOne: CompOneFunc): Integer;

implementation

Procedure Partition(First, Last: Integer; Var SplitIndex: Integer;
          Comp: CompFunc; Swap: SwapProc);

  Var
    Up, Down, Middle: Integer;

  Begin
    Middle := ((Last - First) DIV 2 ) + First;
    Up := First;
    Down := Last;
    Repeat
      While (Comp(Up, Middle) <= 0) And (Up < Last) Do Inc(Up);
      While (Comp(Down, Middle) > 0) And (Down > First) Do Dec(Down);
      If Up < Down Then
         Swap(Up, Down);
    Until Up >= Down;
    SplitIndex := Down;
    Swap(Middle, SplitIndex);
  End;

Procedure QuickSort(First, Last: Integer; Comp: CompFunc; Swap: SwapProc);

  Var
    SplitIndex: Integer;

  Begin
    If First < Last Then
      Begin
        Partition(First, Last, SplitIndex, Comp, Swap);
        QuickSort(First, SplitIndex - 1, Comp, Swap);
        QuickSort(SplitIndex + 1, Last, Comp, Swap);
      End;
  End;

Function BinarySearch(First, Last: Integer; CompOne: CompOneFunc): Integer;

  Var
    Middle, Jfr: Integer;

  Begin
    Repeat
      Middle := ((Last - First) DIV 2 ) + First;
      Jfr := CompOne(Middle);
      If Jfr = 0 Then
        Begin
          BinarySearch := Middle;
          Exit;
        End
      Else If Jfr > 0 Then
        First := Middle
      Else
        Last := Middle;
    Until First = Last;
    BinarySearch := -1;
  End;

end.

