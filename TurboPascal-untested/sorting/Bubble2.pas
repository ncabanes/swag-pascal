(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0005.PAS
  Description: BUBBLE2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
> Does anyone know of a routine or code that would allow for
> a alphbetical sort in pascal?  If so could you mail or
> Write it in this base?  Thanks!

I know of a couple but this is the best and fastest one that I know of

Bubble Sort
}

Type
  StArray = Array [1..10] of String;

Procedure bubble_sort(Var names : StArray);
Var
  i,
  last,
  latest : Integer;
  temp : String;
  exchanged : Boolean;
begin
  last := max_names - 1;
  Repeat
    i := 1;
    exchanged := False;
    latest    := last;
    Repeat
      if names[i] > names[i+1] then
      begin
        temp := names[i];
        names[i] := names[i+1];
        names[i+1] := temp;
        exchanged := True;
        latest := i;
      end;
      inc(i);
    Until not (i <= last);
    last := latest;
  Until not ((last >= 2) and exchanged);
end;

