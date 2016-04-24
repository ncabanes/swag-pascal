(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0015.PAS
  Description: QUICK1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

Unit Qsort;

{

Copyright 1990 Trevor J Carlsen
All rights reserved.

Author:   Trevor J Carlsen
          PO Box 568
          Port Hedland WA 6721
          
A general purpose sorting Unit.


}

Interface

Type
  updown   = (ascending,descending);
  str255   = String;
  dataType = str255;     { the Type of data to be sorted }
  dataptr  = ^dataType;
  ptrArray = Array[1..10000] of dataptr;
  Arrayptr = ^ptrArray;
  
Const 
  maxsize  : Word = 10000;
  SortType : updown = ascending;
 
Procedure QuickSort(Var da; left,right : Word);

{============================================================================}
Implementation
 
Procedure swap(Var a,b : dataptr);  { Swap the Pointers }
  Var  t : dataptr;
  begin
    t := a;
    a := b;
    b := t;
  end;
 
    
Procedure QuickSort(Var da; left,right : Word);
  Var
    d       : ptrArray Absolute da;
    pivot   : dataType;
    lower,
    upper,
    middle  : Word;

  begin
    lower := left;
    upper := right;
    middle:= (left + right) div 2;
    pivot := d[middle]^;
    Repeat
      Case SortType of
      ascending :  begin
                     While d[lower]^ < pivot do inc(lower);
                     While pivot < d[upper]^ do dec(upper);
                   end;
      descending:  begin
                     While d[lower]^ > pivot do inc(lower);
                     While pivot > d[upper]^ do dec(upper);
                   end;
      end; { Case }                    
      if lower <= upper then begin
        { swap the Pointers not the data }
        swap(d[lower],d[upper]);
        inc(lower);
        dec(upper);
      end;
    Until lower > upper;
    if left < upper then QuickSort(d,left,upper);
    if lower < right then QuickSort(d,lower,right);
  end;  { QuickSort }

end.



