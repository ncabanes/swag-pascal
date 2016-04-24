(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0014.PAS
  Description: Pointer Sort
  Author: REYNIR STEFANSSON
  Date: 05-28-93  13:57
*)

{
REYNIR STEFANSSON

Some time ago I wangled myself into a beta testing team For a floppy
disk catalogger called FlopiCat. This is a rather BASIC (in more than one
way) Program, but works well enough.

The built-in sorting routine was a bit quacked, so I wrote my own
external sorter, which is both more versatile and faster (by far) than the
internal one.

     Here it is, in Case someone can use the idea (and code):
}

Program FlopiSrt; { Sorts FlopiCat.Dat. }

Const
  Maximum = 6000; { I don't need that many meself... }
  FName   : String[12] = 'Flopicat.Dat';

Type
  fEntry = Record
    n : Array[1..4] of Char;
    i : Array[1..35] of Char;
    d : Array[1..39] of Char;
  end;

  En1 = Array[1..78] of Char;
  En2 = Record
    n : Array[1..4] of Char;
    f : Array[1..9] of Char;
    e : Array[1..3] of Char;
    z : Array[1..8] of Char;
    t : Array[1..15] of Char;
    d : Array[1..39] of Char;
  end;

  En3 = Record
    f, d : Array[1..39] of Char;
  end;

  pEntry = ^fEntry;

Var
  Entry        : Array [1..Maximum] of pEntry;
  fc           : File of fEntry;
  Rev          : Boolean;
  LoMem        : Pointer;
  i,
  NumOfEntries : Integer;
  nfd          : Char;
  s            : String;

Function ToSwap(i, j : Integer) : Boolean;
Var
  Swop : Boolean;
begin
  Swop := False;
  Case nfd OF
    { Sorting by disk number: }
    'N' : if Entry[i]^.n > Entry[j]^.n then
            Swop := True;
    { Sorting by File information: }
    'I' : if Entry[i]^.i > Entry[j]^.i then
            Swop := True;
    { Sorting by description: }
    'D' : if Entry[i]^.d > Entry[j]^.d then
            Swop := True;
    { Sorting by all the String: }
    'A' : if En1(Entry[i]^) > En1(Entry[j]^) then
            Swop := True;
    { Sorting by File name only: }
    'F' : if En2(Entry[i]^).f > En2(Entry[j]^).f then
            Swop := True;
    { Sorting by File extension only: }
    'E' : if En2(Entry[i]^).e > En2(Entry[j]^).e then
            Swop := True;
    { Sorting by File size: }
    'Z' : if En2(Entry[i]^).z > En2(Entry[j]^).z then
            Swop := True;
    { Sorting by date/time stamp: }
    'T' : if En2(Entry[i]^).t > En2(Entry[j]^).t then
            Swop := True;
    { Sorting by disk number/File info block: }
    'B' : if En3(Entry[i]^).f > En3(Entry[j]^).f then
            Swop := True;
  end;
  ToSwap := Swop xor Rev;
end;

{ if I remember correctly, I settled on using shaker/shuttle sort. }
Procedure SortIt;
Var
  i, j,
  pb, pf,
  pp, pt : Integer;
  t      : pEntry;

  Procedure SwapIt(i, j : Integer);
  begin
    t := Entry[i];
    Entry[i] := Entry[j];
    Entry[j] := t;
  end;

begin
  Write('0    entries processed.');
  i  := 0;
  pt := 2;
  pb := NumOfEntries;
  pf := 0;
  Repeat
    pp := pt;
    Repeat
      if ToSwap(pp - 1, pp) then
      begin
        SwapIt(pp - 1, pp);
        pf := pp;
      end;
      Inc(pp);
    Until pp > pb;

    pb := pf - 1;
    j  := i;
    i  := NumOfEntries - (pb - pt + 2);
    if (i MOD 10) < (j MOD 10) then
      Write(#13, i);
    if pb < pt then
      Exit;
    pp := pb;

    Repeat
      if ToSwap(pp - 1, pp) then
      begin
        SwapIt(pp - 1, pp);
        pf := pp;
      end;
      Dec(pp);
    Until pp < pt;

    pt := pf + 1;
    j  := i;
    i  := NumOfEntries - (pb - pt + 2);
    if (i MOD 10) < (j MOD 10) then
      Write(#13, i);
  Until pb < pt;
end;


