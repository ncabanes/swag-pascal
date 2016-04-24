(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0063.PAS
  Description: Merge Sort for Linked Lists
  Author: PETER TARANTO
  Date: 08-30-96  09:36
*)


{ I've been working on a project for most of this year found the SWAG
group a valuable resource for ideas. I've written a mergesort that I
thought others may find of interest. It is written for a doubly
linked list because that is what I needed, but I'm sure it can be
adapted for a single linked list and with a bit more work probably 
arrays.

On a 486DX-50 it repeatly sorted a list of 20000 elements in less
than 0.9 of a second (unless I've done something wrong with the 
timing).

It is wrapped up in a test program and generates an output file
called 'SORTTEXT.TXT' which includes the initial unsorted list, the
sorted list and the approximate time taken to sort the list. It
should compile straight away.
}

program MergeTest;

uses Dos;{for GetTime}

type
   PNodeType = ^NodeType;

   NodeType = record Val  : integer;   {The Value of the node} 
      Prev : PNodeType; {The Previous Node in the List. This equals nil when first in list} 
      Next : PNodeType; {The Next Node in the List. This equals nil when last in list} 
   end;

var
   TheList      : PNodeType;
   TempList     : PNodeType;

   N            : integer;
   Count        : integer;

   OutFile      : text;

   Hundredths   : word;    {                               }
   Hundredths2  : word;    {                               }
   Seconds      : word;    {                               }
   Seconds2     : word;    {                               }
   Minutes      : word;    {       Used for timing         }
   Minutes2     : word;    {                               }
   Hours        : word;    {                               }
   Hours2       : word;    {                               }
   Total        : longint; {                               }
   Total2       : longint; {                               }

   procedure ShowList(TheList : PNodeType);
   {This procedure will take a List of PNodeType and write it to a file}

   var
      Count    : integer;
      TempList : PNodeType;

   begin
      TempList := TheList;
      Count := 1;
      while TempList <> nil do
      begin
         if TempList^.Prev <> nil then
            writeln(OutFile,'  Prev : ',TempList^.Prev^.Val)
         else
            writeln(OutFile,'  Prev = nil');

         writeln(OutFile,'Val No : ',Count,' is ',TempList^.Val);

         if TempList^.Next <> nil then
            writeln(OutFile,'  Next : ',TempList^.Next^.Val)
         else
            writeln(OutFile,'  Next = nil');

         writeln(OutFile);
         TempList := TempList^.Next;
         inc(Count);
      end;
      writeln(OutFile,'The Node = nil');
      writeln(OutFile);
   end;



   function MergeSort(TheList : PNodeType; N : integer) : PNodeType;
   {This procedure is the MergeSort. It recursively calls itself to sort the
    list}

   var
      TempNode1  : PNodeType;
      TempNode2  : PNodeType;
      Count      : integer;
      Size1      : integer;
      Size2      : integer;
      UsingList1 : boolean;

   begin
      {check for two or less elements}

      if N <= 2 then
      begin
         if N = 1 then               {one element in the list}
            MergeSort := TheList     {a one element list is already sorted}
         else
         begin                       {two elements in the list}

            {if the two elements are already sorted, return the list else
             swap them and return the list}

            if TheList^.Val < TheList^.Next^.Val then
               MergeSort := TheList
            else
            begin
               TempNode1 := TheList;
               TempNode2 := TheList^.Next;
               TempNode1^.Prev := TempNode2;
               TempNode2^.Next := TempNode1;
               TempNode1^.Next := nil;
               TempNode2^.Prev := nil;
               MergeSort := TempNode2;
            end;
         end;
      end
      else
      begin
         {more than two element in the list}

         {split the list in to two half lists}
            {TempNode1 holds the first list}
            {TempNode2 holds the second list}

         TempNode2 := TheList;
         Size1 := N div 2;
         Size2 := n - Size1;
         for Count := 1 to Size1 - 1 do
            TempNode2 := TempNode2^.Next;
         TempNode1 := TempNode2;
         TempNode2 := TempNode2^.Next;
         TempNode1^.Next := nil;
         TempNode2^.Prev := nil;
         TempNode1 := TheList;

         {sort the two half lists}

         TempNode1 := MergeSort(TempNode1,Size1);
         TempNode2 := MergeSort(TempNode2,Size2);


         {Merge the two sorted lists}
            {Select which list to start with}
            {When UsingList1 is true then the list being moved through is
             the first list (TempNode1) else it is the second list
             (TempNode2)}

         if TempNode1^.Val < TempNode2^.Val then
         begin
            MergeSort := TempNode1;
            UsingList1 := true;
         end
         else
         begin
            MergeSort := TempNode2;
            UsingList1 := false;
         end;

         while (TempNode1 <> nil) and (TempNode2 <> nil) do
         begin
            {A procedure could be used to replace the two branches of this
             if statement}

            {This is where the merge takes place}

            if UsingList1 then
            begin
               while (TempNode1^.next <> nil) and
                     (TempNode1^.Next^.Val < TempNode2^.Val) do
                                {^ Sort criteria ^}
                  TempNode1 := TempNode1^.Next;
               TempNode2^.Prev := TempNode1;
               TempNode1 := TempNode1^.Next;
               TempNode2^.Prev^.Next := TempNode2;
               if TempNode1 = nil then
                  exit;
            end
            else
            begin
               while (TempNode2^.next <> nil) and
                     (TempNode2^.Next^.Val < TempNode1^.Val) do
                                {^ Sort criteria ^}
                  TempNode2 := TempNode2^.Next;
               TempNode1^.Prev := TempNode2;
               TempNode2 := TempNode2^.Next;
               TempNode1^.Prev^.Next := TempNode1;
               if TempNode2 = nil then
                  exit;
            end;
            UsingList1 := not UsingList1;
         end;

      end;
   end;


begin
   {Small piece of code to test the sort}
   N := 20000;                        {Change this to vary the number of
                                       elements in the linked list}
   randomize;

   {Create the list}

   writeln('Initialising List');
   new(TheList);
   TheList^.Val := random(500);
   TheList^.Prev := nil;
   TempList := TheList;
   for Count := 2 to N do
   begin
      new(TempList^.Next);
      TempList^.Next^.Prev := TempList;
      TempList := TempList^.Next;
      TempList^.Val := random(500);
   end;
   TempList^.next := nil;

   {Write the list to file}
   writeln('Writing Initial list to file');
   assign(OutFile,'SortText.Txt');              {The name of the output file}
   rewrite(OutFile);
   writeln(OutFile,'----- Initial List -----');
   writeln(OutFile);
   ShowList(TheList);
   close(OutFile);

   writeln('Sorting List of ', N ,' elements');
   {Get the start time}
   GetTime(Hours,Minutes,Seconds,Hundredths);

   {Sort the list}
   TheList := mergesort(TheList,N);

   {Get the end time}
   GetTime(Hours2,Minutes2,Seconds2,Hundredths2);

   writeln('List Sorted');

   {Calculate the difference (I'm sure there's a better way)}
   Total := Hours * 360000 + Minutes * 6000 + Seconds * 100 + Hundredths;
   Total2 := Hours2 * 360000 + Minutes2 * 6000 + Seconds2 * 100 + Hundredths2;

   {Display Time taken}
   writeln('Approx Time Taken : ',Total2 - Total,' hundredths of a second');

   {Write the sorted list and the results to file}
   writeln('Writing Sorted list to File');
   writeln;
   append(OutFile);
   writeln(OutFile,'----- Sorted  List -----');
   writeln(OutFile);
   ShowList(TheList);
   writeln(OutFile,'Approx Time Taken : ',Total2 - Total,' hundredths of a second');
   close(OutFile);

end.

