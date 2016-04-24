(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0017.PAS
  Description: WILDCRD2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:58
*)

{
> Does anyone know how to pass a wildcard Filename to a parameter String and
> have the code grab the actual full Filename?

not quite, but close.  Consider the Function Wild below.  if you should do a
findfirst/findnext and run the Function wild on each found name you get what
you want.
}

Function Wild(FileName, Card : String) : Boolean;
{Returns True if the wildcard description in 'card' matches 'flname'
according to Dos wildcard principles.  The 'card' String MUST have a period!
Example: Wild('test.tat','t*.t?t' returns True}
Var
 c        : Char;
 p,i,n,l  : Byte;

begin
  Wild := True;
  {test For special Case first}
  if Card = '*.*' then
    Exit;
  Wild := False;
  p := Pos('.', Card);
  i := Pos('.', FileName);
  if p = 0 then
  begin
    Writeln('Invalid use of Function "wild".  Program halted.');
    Writeln('Wild card must contain a period.');
    Halt;
  end;
  {test the situation beFore the period}
  n := 1;
  Repeat
    c := UpCase(Card[n]);
    if c = '*' then
      n := p
    else
    if (upCase(FileName[n]) = c) or (c = '?') then
      inc(n)
    else
      Exit;
  Until n >= p;

  {Now check after the period}
  n := p + 1; {one position past the period of the wild card}
  l := Length(FileName);
  Inc(i); {one position past the period of the Filename}
  Repeat
    if n > Length(Card) then
      Exit;
    c := UpCase(Card[n]);
    if c = '*' then
      i := l + 1 {in order to end the loop}
    else
    if (UpCase(FileName[i]) = c) or (c = '?') then
    begin
      Inc(n);
      Inc(i);
    end
    else
      Exit;
  Until i > l;

  Wild := True;
End;
