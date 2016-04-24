(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0060.PAS
  Description: Demo QUICKSORT
  Author: ROBERT BEICHT
  Date: 02-21-96  21:04
*)


{************************************************}
{                                                }
{ QuickSort Demo                                 }
{ Copyright (c) 1985,90 by Borland International } { und: Robert Beicht ;-) }
{                                                }
{************************************************}

program QSort;
{$R-,S-}
uses Crt;

{ This program demonstrates the quicksort algorithm, which      }
{ provides an extremely efficient method of sorting arrays in   }
{ memory. The program generates a list of 1000 random numbers   }
{ between 0 and 29999, and then sorts them using the QUICKSORT  }
{ procedure. Finally, the sorted list is output on the screen.  }
{ Note that stack and range checks are turned off (through the  }
{ compiler directive above) to optimize execution speed.        }

const
  Max = 100;

type                                                                  { ***** }
  PData = ^TData;                                                     { ***** }
  TData = record                                                      { ***** }
    NachName: String[25];                                             { ***** }
    VorName:  String[25];                                             { ***** }
    {..}                                                              { ***** }
  end;                                                                { ***** }
  
  List = array[1..Max] of TData;

var
  Data: List;
  I: Integer;

function Less(var d1,d2:TData): Boolean;                              { ***** }
begin                                                                 { ***** }
  if d1.NachName < d2.NachName then Less := True  else                { ***** }
  if d1.NachName > d2.NachName then Less := False else                { ***** }
    if d1.VorName < d2.VorName then Less := True  else                { ***** }
    if d1.VorName > d2.VorName then Less := False else Less := False; { ***** }
end;                                                                  { ***** }

{ QUICKSORT sorts elements in the array A with indices between  }
{ LO and HI (both inclusive). Note that the QUICKSORT proce-    }
{ dure provides only an "interface" to the program. The actual  }
{ processing takes place in the SORT procedure, which executes  }
{ itself recursively.                                           }

procedure QuickSort(var A: List; Lo, Hi: Integer);

procedure Sort(l, r: Integer);
var
  i, j, x: integer;                                                   { ***** }
  y: TData;                                                           { ***** }
begin
  i := l; j := r; x := (l+r) DIV 2;
  repeat
    while Less(a[i], a[x]) do i := i + 1;                             { ***** }
    while Less(a[x], a[j]) do j := j - 1;                             { ***** }
    if i <= j then
    begin
      y := a[i]; a[i] := a[j]; a[j] := y;
      i := i + 1; j := j - 1;
    end;
  until i > j;
  if l < j then Sort(l, j);
  if i < r then Sort(i, r);
end;

begin {QuickSort};
  Sort(Lo,Hi);
end;

begin {QSort}

  (*Initialisiere List*)
  Sort(List, 1, Count);

end.

