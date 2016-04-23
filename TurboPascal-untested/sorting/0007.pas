{
  ...Well, as Greg Vigneault reminded me, there is a much faster
  method of sorting this sort of data called a "Count" sort. I
  often overlook this method, as it doesn't appear to be a sort
  at all at first glance:
}
Program Count_Sort_Demo;

Const
  co_MaxItem = 200;

Type
  byar_MaxItem = Array[1..co_MaxItem] of Byte;
  byar_256     = Array[0..255] of Byte;

Var
  by_Index   : Byte;
  wo_Index   : Word;
  DataBuffer : byar_MaxItem;
  SortTable  : byar_256;

begin
           (* Initialize the pseudo-random number generator.       *)
  randomize;

           (* Clear the CountSort table.                           *)
  fillChar(SortTable, sizeof(SortTable), 0);

           (* Create random Byte data.                             *)
  For wo_Index := 1 to co_MaxItem do
    DataBuffer[wo_Index] := random(256);

           (* Display random data.                                 *)
  Writeln;
  Writeln('RANDOM Byte DATA');
  For wo_Index := 1 to co_MaxItem do
    Write(DataBuffer[wo_Index]:4);

           (* CountSort the random data.                           *)
  For wo_Index := 1 to co_MaxItem do
    inc(SortTable[DataBuffer[wo_Index]]);

           (* Display the CountSorted data.                        *)
  Writeln;
  Writeln('COUNTSORTED Byte DATA');
  For by_Index := 0 to 255 do
    if (SortTable[by_Index] > 0) then
      For wo_Index := 1 to SortTable[by_Index] do
        Write(by_Index:4)
end.
{
  ...This Type of sort is EXTEMELY fast, even when compared to
  QuickSort, as there is so little data manipulation being done.

>BTW, why are there so many different sorting methods?
>Quick, bubble, Radix.. etc, etc

  ...Because, Not all data is created equally.
  (ie: Some Types of sorts perform well on data that is very
       random, While other Types of sorts perform well on data
       that is "semi-sorted" or "almost sorted".)

}