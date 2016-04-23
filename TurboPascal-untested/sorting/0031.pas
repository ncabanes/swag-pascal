{I wrote a small Program to bench both sort routines we posted. It was an
interesting test, however it did raise a couple questions For me, which I'll
get to in a moment. (The following Program can be used as a skeleton For trying
other sort routines too.)

Needless to say, the routine you posted was dramatically faster than the one I
posted, even though both routines are non-recursive simple sorts.

The maximum efficient load of the routine you posted appears to be about 3000
elements. After that, additonal elements add time exponentially. For example,
it will sort 3000 elements in 5.1 seconds, but 5000 elements takes almost 16
seconds. The sort I posted became un-benchable [bearable] at about 3000
elements when it took over a minute to Complete. I didn't test it beyond this
point.

Here are the results from my 386 33Mhz machine-- your algorithm.

     500 Elements - 0.1   Seconds
    1000 Elements - 0.8   Seconds
    1500 Elements - 1.4   Seconds
    2000 Elements - 2.6   Seconds
    3000 Elements - 5.1   Seconds  <- Peak efficiency reached
    5000 Elements - 15.8  Seconds

Here is the Program I used to benchmark with. I made it so that you could
"tweak" portions of the sort and re-run the Program.

Incidentally, I also Compiled this Program under Stony Brook's Pascal Plus and
was suprised to find that it ran substantially slower. All optimizations on.

Range Checking ($R+) exactly Doubled the time it took to sort.

Changing "Span+1" to Succ(Span) and "total-1" to Pred(total) made the routine
about 3% faster. However the routine then neglected to sort that last two
elements. Adding "Inc(total,2)" solved the problem but I'm not sure why. I did
not expect this behavior. Perhaps someone could explain why?

I added a temporary Pointer Variable to your routine in place of the "NewStr('
...  ')" code you used to simplify it.

and one last thing... Using OPRO's OpInline Function called
"ExchangeLongInts()" to do the swapping instead of using a temporary Var
increased speed another 2% (Evident at > 2000 elements.) However I did not
include this so that anyone interested could Compile and run this without extra
Units.
}

{$A+,B-,D-,E-,F-,G-,I+,L+,N-,O-,P-,Q+,R-,S+,T-,V-,X-,Y+}
{$M 32768,0,655360}

Program Sort_Test;  { Sorting Benchmark Using P. Beeftink's Algorithm }

Type
   SmallArrPtr = ^SmallArr;
   SmallArr    = Array[1..10] of Char;   { Skip String & Length Byte }

   TTimeString = String[20];


Var
   SortArray : Array[1..5000] of SmallArrPtr; { A LARGE Array }

   TickCount : LongInt Absolute $0040:$006C;
 { TickCount : LongInt VOLATILE Absolute $0040:$006C; } { For Pascal+ }
   Tstart,
   Ttime     : LongInt;

{------------------------------------------------------------------------}
Procedure StartTiming;
begin
  TStart := TickCount;

  {start at the beginning of a tick!}
  Repeat Until TStart <> TickCount;

  TStart := TickCount;

end;
{------------------------------------------------------------------------}
Procedure StopTiming;
begin
  TTime := TickCount - TStart;
end;
{------------------------------------------------------------------------}
Function Elapsed : TTimeString;
Var Temp : TTimeString;
   Sec10 : LongInt;
begin

  Sec10 := TTime * 2470 div 4497;
  Str( Sec10 : 4, Temp );

  if Temp[1] = ' ' then Temp[1] := '0';

  Inc( Temp[0] );
  Temp[ Length(Temp) ] := Temp[ Pred( Length( Temp ) ) ];
  Temp[ Pred( length( Temp ) ) ] := '.';

  Elapsed := Temp;
end;
{------------------------------------------------------------------------}
Procedure MakeRandomStrings( NumtoMake : Word );
Var RNum,
    I,S  : Word;
    Temp : String;
begin

  Temp := '';
  Temp[0] := Chr( 10 );
  Randomize;

  For I := 1 to NumtoMake do
  begin

    For S := 1 to 10 do     { Create Random Strings 10 Chars in length }
    begin
      RNum := Random(26);
      Temp[S] := Chr( RNum + 65 );
    end;

    Move( Temp[1], SortArray[I]^, 10 );

  end;

end; { Proc }
{------------------------------------------------------------------------}
Procedure KDSort( total : Word );
  {-My simple sort routine as posted in Pascal Echo }
  { With 2 slight modifications                     }
Var
   i,j,
   Current : Word;
   TempPtr : Pointer;
begin

  For I := 1 to total do
  begin

    Current := I;

    For J := Succ(I) to total do
    begin
      if SortArray[J]^ < SortArray[Current]^ then
      begin
         TempPtr            := SortArray[j];
         SortArray[j]       := SortArray[Current];
         SortArray[Current] := TempPtr;
      end; {if}
    end; {For}

  end; {For}

end;
{------------------------------------------------------------------------}
Procedure PBSort(total : Integer);
  {-Peter Beeftink's Sort as Posted in Pascal Echo }
  { Also With slight modifications                 }
Var
   I,j     : Integer;
   Span    : Integer;
   TempPtr : Pointer;
begin

  Inc(total,2);   { Required to Compensate For PRED and SUCC ? }

  Span := total SHR $01;

  While Span > 0 do
  begin

    For I := Span to Pred(total) {total-1} do
    begin

      For j := (I - Succ(Span) {Span+1} ) Downto 1 do
        if (SortArray[j]^ <= SortArray[j+Span]^) then j := 1 else
        begin
          TempPtr           := SortArray[j];
          SortArray[j]      := SortArray[j+Span];
          SortArray[j+Span] := TempPtr;
        end;

    end; {For}

    Span := Span SHR $01; { This does help speed over Span div 2! }

  end; {WhIle}

end;
{------------------------------------------------------------------------}
Procedure Do_Sorting( SortAmount : Word );
begin

  MakeRandomStrings(SortAmount);

  Write('Sorting... ');

  StartTiming;

  PBSort(SortAmount); { Change to KDSort() to bench second sort routine }

  StopTiming;

  WriteLn(SortAmount:5,' Elements - ',Elapsed,' Seconds');

end;
{------------------------------------------------------------------------}
Var C : Word;

begin

  if MaxAvail < 5000 * Sizeof(SmallArr) then Halt; { not enough memory! }

  For C := 1 to 5000 do   { pre-allocate up front }
    GetMem(SortArray[C],Sizeof(SmallArr));


  Do_Sorting( 500   );   { Add more Do_Sorting()'s For whatever count }
  Do_Sorting( 1000  );   { you wish to test with.                     }
  Do_Sorting( 1500  );
  Do_Sorting( 2000  );
  Do_Sorting( 3000  );
  Do_Sorting( 5000  );


  { Un-comment the following if you wish to see the sorted output }

  {
  For C := 1 to 5000 do   { Change 5000 to the amount you sorted }
    WriteLn( SortArray[C]^ );


  For C := 1 to 5000 do
    FreeMem(SortArray[C],Sizeof(SmallArr));

end.
{
I plugged in a QuickSort algorithm in the "skeleton" Program in my previous
message to test perFormance. Here are the results:

     500 Elements - 0.1 Seconds
    1000 Elements - 0.2 Seconds
    1500 Elements - 0.4 Seconds
    2000 Elements - 0.6 Seconds
    3000 Elements - 0.9 Seconds
    5000 Elements - 1.8 Seconds

Very fast indeed. I modified the algorithm to sort only by Pointers, and
optimized a couple spots. Again, a slight speed increase is noted using OPRO's
ExchangeLongInts() in leu of using temporary Variables in 1 spot. if you have
OPRO, replace them and you reduce the number of instructions by 2 per
iteration.

This is a split-list recursive sort. Works by making a pass through the entire
Array first and moves all "small" data to the left, and all "Large" data to the
right. then it sorts each half seperately.

Take the following code segment and "plug" it into the skeleton in my previous
message. then change the "PBSort(SortAmount)" to "QuickSort(SortAmount)" to run
the tests.

Here is the code segment:

{------------------------------------------------------------------------}
Procedure QuickSort( total : Integer );
  {------------------------------------------}
  Procedure recQuickSort( L, R : Integer );
  Var K,I,J   : Integer;
      T,
      Temp    : Pointer;

  begin

    if L < R then
    begin
      T := SortArray[L];
      I := Pred(L);
      J := L;
      K := Succ(R);

      While Succ(J) < K do
       if SortArray[Succ(J)]^ < SmallArrPtr(T)^ then
       begin
         Inc(I,1);
         Inc(J,1);
         SortArray[I] := SortArray[J];
         SortArray[j] := T;
       end {if}
       else
       if SortArray[Succ(J)]^ > SmallArrPtr(T)^ then
       begin
         Dec(K,1);
         Temp := SortArray[K];
         SortArray[K] := SortArray[Succ(J)];
         SortArray[Succ(J)] := Temp;
       end {if}
       else
       Inc(J,1);

       recQuickSort(L,I);
       recQuickSort(K,R);

    end; { if L < R }

  end; { Proc recQuickSort }
  {------------------------------------------}

begin

  recQuickSort(1,total);

end;{QuickSort}
{------------------------------------------------------------------------}
