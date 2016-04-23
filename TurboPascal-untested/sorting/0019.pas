{
>I'm in need of a FAST way of finding the largest and the smallest
>30 numbers out of about 1000 different numbers.

  ...Assuming that the 1000 numbers are in random-order, I imagine
  that the simplest (perhaps fastest too) method would be to:

    1- Read the numbers in an Array.

    2- QuickSort the Array.

    3- First 30 and last 30 of Array are the numbers you want.

  ...Here's a QuickSort demo Program that should help you With the
  sort:
}

{$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S+,V-}
{$M 60000,0,0}

Program QuickSort_Demo;
Uses
  Crt;

Const
  co_MaxItem = 30000;

Type
  Item    = Word;
  ar_Item = Array[1..co_MaxItem] of Item;


  (***** QuickSort routine.                                           *)
  (*                                                                  *)
Procedure QuickSort({update} Var ar_Data  : ar_Item;
                    {input }     wo_Left,
                                 wo_Right : Word);
Var
  Pivot,
  TempItem  : Item;
  wo_Index1,
  wo_Index2 : Word;
begin
  wo_Index1 := wo_Left;
  wo_Index2 := wo_Right;
  Pivot := ar_Data[(wo_Left + wo_Right) div 2];
  Repeat
    While (ar_Data[wo_Index1] < Pivot) do
      inc(wo_Index1);
    While (Pivot < ar_Data[wo_Index2]) do
      dec(wo_Index2);
    if (wo_Index1 <= wo_Index2) then
      begin
        TempItem := ar_Data[wo_Index1];
        ar_Data[wo_Index1] := ar_Data[wo_Index2];
        ar_Data[wo_Index2] := TempItem;
        inc(wo_Index1);
        dec(wo_Index2)
      end
    Until (wo_Index1 > wo_Index2);
    if (wo_Left < wo_Index2) then
      QuickSort(ar_Data, wo_Left, wo_Index2);
    if (wo_Index1 < wo_Right) then
      QuickSort(ar_Data, wo_Index1, wo_Right)
end;        (* QuickSort.                                           *)

Var
  wo_Index  : Word;
  ar_Buffer : ar_Item;

begin
  Write('Creating ', co_MaxItem, ' random numbers... ');
  For wo_Index := 1 to co_MaxItem do
    ar_Buffer[wo_Index] := random(65535);
  Writeln('Finished!');
  Write('Sorting  ', co_MaxItem, ' random numbers... ');
  QuickSort(ar_Buffer, 1, co_MaxItem);
  Writeln('Finished!');
  Writeln;
  Writeln('Press the <ENTER> key to display all ', co_MaxItem,
          ' sorted numbers...');
  readln;
  For wo_Index := 1 to co_MaxItem do
    Write(ar_Buffer[wo_Index]:8)
end.
