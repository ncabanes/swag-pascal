(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0017.PAS
  Description: Quick Sort
  Author: TEK CHAN
  Date: 05-28-93  13:57
*)

{ File that will teach me how to quick sort?  I know how quick sort works
 but I don't know why my Program doesn't sort properaly.  Sometimes it goes
 through one cycle of sort and sometimes it goes through two cycles of sort
 but it never sorts it Completely! Tek Chan

Here is some generic source code, change it to suit your needs/Types:
}

Procedure Split(Var Info: ArrayType; First: Integer; Last: Integer; Var
SplitPt1: Integer; Var SplitPt2: Integer);

Var SplitVal, Temp: ArrayElementType;

begin
  SplitVal:=Info[(First+Last) div 2];
  Repeat
    While Info[First] < SplitVal do
      First:=First+1;
    While Info[Last] > SplitVal do
      Last:=Last-1;
    if First <= Last then
      begin
        Temp:=Info[First];
        Info[First]:=Info[Last];
        Info[Last]:=Temp;
        First:=First+1;
        Last:=Last-1;
      end
  Until First > Last;
  SplitPt1:=First;
  SplitPt2:=Last;
end;

Procedure QuickSort(Var Info: ArrayType;  First:Integer;  Last: Integer);

Var SplitPt1, SplitPt2: Integer;

begin
  if First < Last then
    begin
      Split(Info, First, Last, SplitPt1, SplitPt2);
      if SplitPt1 < Last
        then QuickSort(Info, SplitPt1, Last);
      if First < SplitPt2
        then QuickSort(Info, First, SplitPt2);
    end
end;

{
This is a -very- fast sort, much faster than any other I have.  Does a
non-recursive version exist?  Are there any faster sorts?   Brian
}
