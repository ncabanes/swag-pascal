(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0018.PAS
  Description: QUICK4.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

Unit qsort;

Interface

Procedure quicksort(Var s; left,right : Word);

Implementation

Procedure quicksort(Var s; left,right : Word; SortType: sType);
  { On the first call left should always be = to min and right = to max }
  Var
    data      : DataArr Absolute s;
    pivotStr,
    tempStr   : String;
    pivotLong,
    tempLong  : LongInt
    lower,
    upper,
    middle    : Word;

  Procedure swap(Var a,b);
    Var x : DirRec Absolute a;
        y : DirRec Absolute b;
        t : DirRec;
    begin
      t := x;
      x := y;
      y := t;
    end;

  begin
    lower := left;
    upper := right;
    middle:= (left + right) div 2;
    Case SortType of
      _name: pivotStr   := data[middle].name;
      _ext : pivotStr   := data[middle].ext;
      _size: pivotLong  := data[middle].Lsize;
      _date: pivotLong  := data[middle].Ldate;
    end; { Case SortType }
    Repeat
      Case SortType of
        _name: begin
                 While data[lower].name < pivotStr do inc(lower);
                 While pivotStr < data[upper].name do dec(upper);
               end;
        _ext : begin
                 While data[lower].ext < pivotStr do inc(lower);
                 While pivotStr < data[upper].ext do dec(upper);
               end;
        _size: begin
                 While data[lower].Lsize < pivotLong do inc(lower);
                 While pivotLong < data[upper].Lsize do dec(upper);
               end;
        _date: begin
                 While data[lower].Ldate < pivotLong do inc(lower);
                 While pivotLong < data[upper].Ldate do dec(upper);
               end;
      end; { Case SortType }
      if lower <= upper then begin
        swap(data[lower],data[upper]);
        inc(lower);
        dec(upper);
       end;
    Until lower > upper;
    if left < upper then quicksort(data,left,upper);
    if lower < right then quicksort(data,lower,right);
  end; { quicksort }








