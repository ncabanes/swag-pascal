const
  MaxItem = 30000;

type
  Item = word;
  Ar1K = array[1..MaxItem] of Item;


  (***** Selection sort routine.                                      *)
  (*                                                                  *)
  procedure SelectionSort ({update} var Data : Ar1K;
                           {input }     ItemsToSort : word);
  var
    Temp   : Item;
    Min,
    Index1,
    Index2 : word;
  begin
    for Index1 := 1 to pred(ItemsToSort) do
      begin
        Min := Index1;
        for Index2 := succ(Index1) to ItemsToSort do
          if Data[Index2] < Data[Min] then
            Min := Index2;
        Temp := Data[Min];
        Data[Min] := Data[Index1];
        Data[Index1] := Temp
      end
  end;        (* SelectionSort.                                       *)


  (***** Insertion sort routine.                                      *)
  (*                                                                  *)
  procedure InsertionSort ({update} var Data : Ar1K;
                           {input }     ItemsToSort : word);
  var
    Temp   : Item;
    Index1,
    Index2 : word;
  begin
    for Index1 := 2 to ItemsToSort do
      begin
        Temp := Data[Index1];
        Index2 := Index1;
        while (Data[pred(Index2)] > Temp) do
          begin
            Data[Index2] := Data[pred(Index2)];
            dec(Index2)
          end;
        Data[Index2] := Temp
      end
  end;        (* InsertionSort.                                       *)


  (***** Bubble sort routine.                                         *)
  (*                                                                  *)
  procedure BubbleSort ({update} var Data : Ar1K;
                        {input }     ItemsToSort : word);
  var
    Temp   : Item;
    Index1,
    Index2 : word;
  begin
    for Index1 := ItemsToSort downto 1 do
      for Index2 := 2 to Index1 do
        if (Data[pred(Index2)] > Data[Index2]) then
          begin
            Temp := Data[pred(Index2)];
            Data[pred(Index2)] := Data[Index2];
            Data[Index2] := Temp
          end
  end;        (* BubbleSort.                                          *)

  (***** Shell sort routine.                                          *)
  (*                                                                  *)
  procedure ShellSort ({update} var Data : Ar1K;
                       {input }     ItemsToSort : word);
  var
    Temp   : Item;
    Index1, Index2, Index3 : word;
  begin
    Index3 := 1;
    repeat
      Index3 := succ(3 * Index3)
    until (Index3 > ItemsToSort);
    repeat
      Index3 := (Index3 div 3);
      for Index1 := succ(Index3) to ItemsToSort do
        begin
          Temp := Data[Index1];
          Index2 := Index1;
          while (Data[(Index2 - Index3)] > Temp) do
            begin
              Data[Index2] := Data[(Index2 - Index3)];
              Index2 := (Index2 - Index3);
              if (Index2 <= Index3) then
                break
            end;
          Data[Index2] := Temp
        end
    until (Index3 = 1)
  end;        (* ShellSort.                                           *)


  (***** QuickSort routine.                                           *)
  (*                                                                  *)
  procedure QuickSort({update} var Data : Ar1K;
                      {input }     Left,
                                   Right : word);
  var
    Temp   : Item;
    Index1, Index2, Pivot  : word;
  begin
    Index1 := Left;
    Index2 := Right;
    Pivot := Data[(Left + Right) div 2];
    repeat
      while (Data[Index1] < Pivot) do
        inc(Index1);
      while (Pivot < Data[Index2]) do
        dec(Index2);
      if (Index1 <= Index2) then
        begin
          Temp := Data[Index1];
          Data[Index1] := Data[Index2];
          Data[Index2] := Temp;
          inc(Index1);
          dec(Index2)
        end
      until (Index1 > Index2);
      if (Left < Index2) then
        QuickSort(Data, Left, Index2);
      if (Index1 < Right) then
        QuickSort(Data, Index1, Right)
  end;        (* QuickSort.                                           *)

  (***** Radix Exchange sort routine.                                 *)
  (*                                                                  *)
  procedure RadixExchange ({update} var Data   : ar1K;
                           {input }     ItemsToSort,
                                        Left,
                                        Right  : word;
                                        BitNum : shortint);
  var
    Temp   : Item;
    Index1, Index2 : word;
  begin
    if (Right > Left) and ( BitNum >= 0) then
      begin
        Index1 := Left;
        Index2 := Right;
        repeat
          while (((Data[Index1] shr BitNum) AND 1) = 0)
          and (Index1 < Index2) do
            inc(Index1);
          while (((Data[Index2] shr BitNum) AND 1) = 1)
          and (Index1 < Index2) do
            dec(Index2);
          Temp := Data[Index1];
          Data[Index1] := Data[Index2];
          Data[Index2] := Temp
        until (Index2 = Index1);
        if (((Data[Right] shr BitNum) AND 1) = 0) then
          inc(Index2);
        RadixExchange(Data, ItemsToSort, Left, pred(Index2),
                      pred(BitNum));
        RadixExchange(Data, ItemsToSort, Index2, Right, pred(BitNum))
      end
  end;        (* RadixExchange.                                       *)


(*
                               - Guy
---
 ■ DeLuxe²/386 1.25 #5060 ■

*)