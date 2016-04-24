(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0078.PAS
  Description: Reading Large Amounts of Data
  Author: JON LOUIS PECCARELLI
  Date: 05-26-95  23:24
*)

{
From: jonpecc@alpha1.csd.uwm.edu (Jon Louis Peccarelli)
}
unit CSV;
{$X+}

interface

uses winstack, Strings;

var
  Stack: StackType;

procedure ReadLargeData(var handle: text; delimiter: char; var code: integer;
var temppchar: pchar);

implementation

{ Data is returned in temppchar and code is returned (0 if ok, -1 if error)}
procedure ReadLargeData(var handle: text; delimiter: char; var code: integer;
var temppchar: pchar);
var
  prevchar: char;
  okcontinue: boolean;
  ch: array[0..1] of char;
  tempch: char;
  counter: integer;
  charptr: pointer;
  index : word;
  x : word;
begin
{ Initializes a stack }
  CreateStack(Stack);

{ Initialize var's }
  temppchar := '';
  index := 0;
  code := 0;
  okcontinue := true;
  prevchar := #0;
  ch[0] := ' ';
  ch[1] := #0;

  while (ch[0] = ' ') do
    read(handle, ch[0]);

  while (okcontinue) do
  begin
    if (prevchar = #0) and (ch[0] = '"') then
    begin
      char(charptr) := ch[0];
      push(stack, charptr);
    end
    else if (prevchar = '"') and (ch[0] = '"') then
    begin
      pop(stack, charptr);
      ch[0] := char(charptr);
      strcat(temppchar, ch);
    end
    else if (ch[0] = '"') then
    begin
      char(charptr) := ch[0];
      push(stack, charptr)
    end
    else if (ch[0] = delimiter) or eoln(handle) or eof(handle) or
         (ch[0] = #13) then
    begin
      counter := 0;
      while not(emptystack(stack)) do
      begin
        pop(stack, charptr);
        tempch := char(charptr);
        inc(counter,1);
      end;
      if (counter = 1) then
      begin
        char(charptr) := tempch;
        push(stack, charptr);
        strcat(temppchar, ch);
      end
      else if (counter = 2) or (counter = 0) then
        okcontinue := false;
      if eoln(handle) then readln(handle);
    end
    else
    begin
      strcat(temppchar, ch);
    end;
    prevchar := ch[0];
    if not(eof(handle)) then
      read(handle, ch[0]);
  end;
  if eof(handle) then code := -1;
  DestroyStack(Stack);
end;


end.

