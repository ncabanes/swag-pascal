{
 TB>> I am having a bit of difficulty figuring out how to
 TB>> sort an array of records by numerical or alphabetical order.
 TB>> Here's an example of my record set up:

        This a 'small' example of record quicksort.
}

Program SortArrayOfRec;

uses  Crt;

type

 Str34=string[34];

 Rec=Record
      Name:Str34;
      Number1,
      Number2 : LongInt;
     end;

type CmpMinFunc=Function(var r1,r2:Rec):boolean;

var

 RecArray:array[1..1400] of Rec;

{ Compare functions }

Function Name(var r1,r2:Rec):boolean; far;
begin
 Name:=r1.Name<r2.Name;
end;

Function Number1(var r1,r2:Rec):boolean; far;
begin
 Number1:=r1.Number1<r2.Number1;
end;

Function Number2(var r1,r2:Rec):boolean; far;
begin
 Number2:=r1.Number2<r2.Number2;
end;

{ QuickSort method }

Procedure Sort(t,b:integer; Cmp:CmpMinFunc);

Procedure QuickSort(l,r:integer);
var i,j:integer; x,y:Rec;
begin
 i:=l;
 j:=r;
 x:=RecArray[(l+r) div 2];
 repeat
  while Cmp(RecArray[i],x) do inc(i);
  while Cmp(x,RecArray[j]) do dec(j);
  if i<=j
  then begin
        y:=RecArray[i];
        RecArray[i]:=RecArray[j];
        RecArray[j]:=y;
        inc(i);
        dec(j);
       end;
 until i>j;
 if l<j then QuickSort(l,j);
 if i<r then QuickSort(i,r);
end;

begin                                   { Procedure Sort }
 QuickSort(t,b);
end;

{ Demo procedures }

Procedure List(s:string);
var n:byte;
begin
 WriteLn(s);
 for n:=1 to 9 do
  with RecArray[n] do
   WriteLn(n,'     ',Name,Number1:6,Number2:6);
 WriteLn;
 n:=Ord(ReadKey);
end;

var   n:byte;

begin
 ClrScr;
 Randomize;
 for n:=1 to 9 do                       { Fill RecArray with ... }
  with RecArray[n] do                   { random datas }
   begin
    Name:=Chr(65+Random(25));
    Number1:=Random(65535);
    Number2:=Random(65535);
   end;
 List('Datas');

 Sort(1,9,Name);                        { Sort on Name }
 List('Sort on Name');
 Sort(1,9,Number1);                     { Sort on Number1 }
 List('Sort on Number1');
 Sort(1,9,Number2);                     { Sort on Number2 }
 List('Sort on Number2');
end.
