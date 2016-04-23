
{ Updated SORTING.SWG on May 26, 1995 }

{
>I've been programming for a couple years now, but there are certain things
>that you seldom just figure out on your own.  One of them is the multitude
>of standard sorting techniques.  I did learn these, however, in a class I
>took last year in Turbo Pascal.  Let's see, Bubble Sort, Selection Sort,
>Quick Sort..  I think that's what they were called.  Anyway, if anyone
>has the time and desire I'd appreciate a quick run-down of each and if
>possible some source for using them on a linked list.  I remember most of
>the code to do them on arrays, but I forget which are the most efficient
>for each type of data.

Here is a program that I was given to demonstrate 8 different types of sorts.
I don't claim to know how they work, but it does shed some light on what the
best type probably is.  BTW, it can be modified to allow for a random number
of sort elements (up to maxint div 10 I believe).

   ALLSORT.PAS: Demonstration of various sorting methods.
                Released to the public domain by Wayel A. Al-Wohaibi.

   ALLSORT.PAS was written in Turbo Pascal 3.0 (but compatible with
   TP6.0) while taking a pascal course in 1988. It is provided as is,
   to demonstrate how sorting algorithms work. Sorry, no documentation
   (didn't imagine it would be worth releasing) but bugs are included
   too!

   ALLSORT simply shows you how elements are rearranged in each
   iteration of each of the eight popular sorting methods.
}

program SORTINGMETHODS;
uses
  Crt;

const
  N = 14;                              (* NO. OF DATA TO BE SORTED *)
  Digits = 3;                          (* DIGITAL SIZE OF THE DATA *)
  Range = 1000;                        (* RANGE FOR THE RANDOM GENERATOR *)

type
  ArrayType = array[1..N] of integer;
  TwoDimension = array[0..9, 1..N] of integer; (* FOR RADIX SORT ONLY *)

var
  Data : ArrayType;
  D : integer;

  (*--------------------------------------------------------------------*)

  procedure GetSortMethod;
  begin
    clrscr;
    writeln;
    writeln('                          CHOOSE:          ');
    writeln('                                           ');
    writeln('                      1 FOR SELECT SORT    ');
    writeln('                      2 FOR INSERT SORT    ');
    writeln('                      3 FOR BUBBLE SORT    ');
    writeln('                      4 FOR SHAKE  SORT    ');
    writeln('                      5 FOR HEAP   SORT    ');
    writeln('                      6 FOR QUICK  SORT    ');
    writeln('                      7 FOR SHELL  SORT    ');
    writeln('                      8 FOR RADIX  SORT    ');
    writeln('                      9 TO EXIT ALLSORT    ');
    writeln('                                           ');
    writeln;
    readln(D)
  end;

  procedure LoadList;
  var
    I : integer;
  begin
    for I := 1 to N do
      Data[I] := random(Range)
  end;

  procedure ShowInput;
  var
    I : integer;
  begin
    clrscr;
    write('INPUT :');
    for I := 1 to N do
      write(Data[I]:5);
    writeln
  end;

  procedure ShowOutput;
  var
    I : integer;
  begin
    write('OUTPUT:');
    for I := 1 to N do
      write(Data[I]:5)
  end;

  procedure Swap(var X, Y : integer);
  var
    Temp : integer;
  begin
    Temp := X;
    X := Y;
    Y := Temp
  end;

  (*-------------------------- R A D I X   S O R T ---------------------*)

  function Hash(Number, H : integer) : integer;
  begin
    case H of
      3 : Hash := Number mod 10;
      2 : Hash := (Number mod 100) div 10;
      1 : Hash := Number div 100
    end
  end;

  procedure CleanArray(var TwoD : TwoDimension);
  var
    I, J : integer;
  begin
    for I := 0 to 9 do
      for J := 1 to N do
        TwoD[I, J] := 0
  end;

  procedure PlaceIt(var X : TwoDimension; Number, I : integer);
  var
    J : integer;
    Empty : boolean;
  begin
    J := 1;
    Empty := false;
    repeat
      if (X[I, J] > 0) then
        J := J + 1
      else
        Empty := true;
    until (Empty) or (J = N);
    X[I, J] := Number
  end;

  procedure UnLoadIt(X : TwoDimension; var Passed : ArrayType);
  var
    I,
    J,
    K : integer;
  begin
    K := 1;
    for I := 0 to 9 do
      for J := 1 to N do
        begin
          if (X[I, J] > 0) then
            begin
              Passed[K] := X[I, J];
              K := K + 1
            end
        end
  end;

  procedure RadixSort(var Pass : ArrayType; N : integer);
  var
    Temp : TwoDimension;
    Element,
    Key,
    Digit,
    I : integer;
  begin
    for Digit := Digits downto 1 do
      begin
        CleanArray(Temp);
        for I := 1 to N do
          begin
            Element := Pass[I];
            Key := Hash(Element, Digit);
            PlaceIt(Temp, Element, Key)
          end;
        UnLoadIt(Temp, Pass);
        ShowOutput;
        readln
      end
  end;

  (*-------------------------- H E A P   S O R T -----------------------*)

  procedure ReHeapDown(var HEAPData : ArrayType; Root, Bottom : integer);
  var
    HeapOk : boolean;
    MaxChild : integer;
  begin
    HeapOk := false;
    while (Root * 2 <= Bottom)
    and not HeapOk do
      begin
        if (Root * 2 = Bottom) then
          MaxChild := Root * 2
        else
          if (HEAPData[Root * 2] > HEAPData[Root * 2 + 1]) then
            MaxChild := Root * 2
          else
            MaxChild := Root * 2 + 1;
        if (HEAPData[Root] < HEAPData[MaxChild]) then
          begin
            Swap(HEAPData[Root], HEAPData[MaxChild]);
            Root := MaxChild
          end
        else
          HeapOk := true
      end
  end;

  procedure HeapSort(var Data : ArrayType; NUMElementS : integer);
  var
    NodeIndex : integer;
  begin
    for NodeIndex := (NUMElementS div 2) downto 1 do
      ReHeapDown(Data, NodeIndex, NUMElementS);
    for NodeIndex := NUMElementS downto 2 do
      begin
        Swap(Data[1], Data[NodeIndex]);
        ReHeapDown(Data, 1, NodeIndex - 1);
        ShowOutput;
        readln;
      end
  end;

  (*-------------------------- I N S E R T   S O R T -------------------*)

  procedure StrInsert(var X : ArrayType; N : integer);
  var
    J,
    K,
    Y : integer;
    Found : boolean;
  begin
    for J := 2 to N do
      begin
        Y := X[J];
        K := J - 1;
        Found := false;
        while (K >= 1)
        and (not Found) do
          if (Y < X[K]) then
            begin
              X[K + 1] := X[K];
              K := K - 1
            end
          else
            Found := true;
        X[K + 1] := Y;
        ShowOutput;
        readln
      end
   end;

  (*-------------------------- S H E L L   S O R T ---------------------*)

  procedure ShellSort(var A : ArrayType; N : integer);
  var
    Done : boolean;
    Jump,
    I,
    J : integer;
  begin
    Jump := N;
    while (Jump > 1) do
      begin
        Jump := Jump div 2;
        repeat
          Done := true;
          for J := 1 to (N - Jump) do
            begin
              I := J + Jump;
              if (A[J] > A[I]) then
                begin
                  Swap(A[J], A[I]);
                  Done := false
                end;
            end;
        until Done;
        ShowOutput;
        readln
      end
  end;

  (*-------------------------- B U B B L E   S O R T -------------------*)

  procedure BubbleSort(var X : ArrayType; N : integer);
  var
    I,
    J : integer;
  begin
    for I := 2 to N do
      begin
        for J := N downto I do
          if (X[J] < X[J - 1]) then
            Swap(X[J - 1], X[J]);
        ShowOutput;
        readln
      end
  end;

  (*-------------------------- S H A K E   S O R T ---------------------*)

  procedure ShakeSort(var X : ArrayType; N : integer);
  var
    L,
    R,
    K,
    J : integer;
  begin
    L := 2;
    R := N;
    K := N;
    repeat
      for J := R downto L do
        if (X[J] < X[J - 1]) then
          begin
            Swap(X[J], X[J - 1]);
            K := J
          end;
      L := K + 1;
      for J := L to R do
        if (X[J] < X[J - 1]) then
          begin
            Swap(X[J], X[J - 1]);
            K := J
          end;
      R := K - 1;
      ShowOutput;
      readln;
    until L >= R
  end;

  (*-------------------------- Q W I C K   S O R T ---------------------*)

  procedure Partition(var A : ArrayType; First, Last : integer);
  var
    Right,
    Left : integer;
    V : integer;
  begin
    V := A[(First + Last) div 2];
    Right := First;
    Left := Last;
    repeat
      while (A[Right] < V) do
        Right := Right + 1;
      while (A[Left] > V) do
        Left := Left - 1;
      if (Right <= Left) then
        begin
          Swap(A[Right], A[Left]);
          Right := Right + 1;
          Left := Left - 1
        end;
    until Right > Left;
    ShowOutput;
    readln;
    if (First < Left) then
      Partition(A, First, Left);
    if (Right < Last) then
      Partition(A, Right, Last)
  end;

  procedure QuickSort(var List : ArrayType; N : integer);
  var
    First,
    Last : integer;
  begin
    First := 1;
    Last := N;
    if (First < Last) then
      Partition(List, First, Last)
  end;

  (*-------------------------- S E L E C T   S O R T -------------------*)

  procedure StrSelectSort(var X : ArrayType; N : integer);
  var
    I,
    J,
    K,
    Y : integer;
  begin
    for I := 1 to N - 1 do
      begin
        K := I;
        Y := X[I];
        for J := (I + 1) to N do
          if (X[J] < Y) then
            begin
              K := J;
              Y := X[J]
            end;
        X[K] := X[J];
        X[I] := Y;
        ShowOutput;
        readln
      end
  end;

  (*--------------------------------------------------------------------*)

  procedure Sort;
  begin
    case D of
      1 : StrSelectSort(Data, N);
      2 : StrInsert(Data, N);
      3 : BubbleSort(Data, N);
      4 : ShakeSort(Data, N);
      5 : HeapSort(Data, N);
      6 : QuickSort(Data, N);
      7 : ShellSort(Data, N);
      8 : RadixSort(Data, N);
    else
     writeln('BAD INPUT')
    end
  end;

  (*-------------------------------------------------------------------*)

BEGIN
  GetSortMethod;
  while (D <> 9) do
    begin
      LoadList;
      ShowInput;
      Sort;
      writeln('PRESS ENTER TO RETURN');
      readln;
      GetSortMethod
    end
END.

