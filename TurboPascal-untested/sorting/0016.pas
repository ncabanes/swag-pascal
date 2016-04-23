{...This is as generic a QuickSort as I currently use:
}
{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,R-,S-,T-,V-}
{$M 60000,0,0}

Program QuickSortDemo;
Uses
  Crt;

Const
  coMaxItem = 30000;

Type
  Item   = Word;
  arItem = Array[1..coMaxItem] of Item;

  (***** QuickSort routine.                                           *)
  (*                                                                  *)
Procedure QuickSort({update} Var arData  : arItem;
                      {input }     woLeft,
                                   woRight : Word);
Var
  Pivot,
  TempItem : Item;
  woIndex1,
  woIndex2 : Word;
begin
  woIndex1 := woLeft;
  woIndex2 := woRight;
  Pivot := arData[(woLeft + woRight) div 2];
  Repeat
    While (arData[woIndex1] < Pivot) do
      inc(woIndex1);
    While (Pivot < arData[woIndex2]) do
      dec(woIndex2);
    if (woIndex1 <= woIndex2) then
      begin
        TempItem := arData[woIndex1];
        arData[woIndex1] := arData[woIndex2];
        arData[woIndex2] := TempItem;
        inc(woIndex1);
        dec(woIndex2)
      end
    Until (woIndex1 > woIndex2);
    if (woLeft < woIndex2) then
      QuickSort(arData, woLeft, woIndex2);
    if (woIndex1 < woRight) then
      QuickSort(arData, woIndex1, woRight)
end;        (* QuickSort.                                           *)

Var
  woIndex : Word;
  Buffer  : arItem;

begin
  Write('Creating ', coMaxItem, ' random numbers... ');
  For woIndex := 1 to coMaxItem do
    Buffer[woIndex] := random(65535);
  Writeln('Finished!');
  Write('Sorting  ', coMaxItem, ' random numbers... ');
  QuickSort(Buffer, 1, coMaxItem);
  Writeln('Finished!');
  Writeln;
  Writeln('Press the <ENTER> key to display all ', coMaxItem,
          ' sorted numbers...');
  readln;
  For woIndex := 1 to coMaxItem do
    Write(Buffer[woIndex]:8)
end.
