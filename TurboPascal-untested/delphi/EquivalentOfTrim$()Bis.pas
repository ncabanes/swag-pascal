(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0351.PAS
  Description: Equivalent of Trim$()
  Author: JOSEPH BUI
  Date: 01-02-98  07:33
*)

Solution 2 
From: jbui@scd.hp.com (Joseph Bui)

For Mid$, use Copy(S: string; start, length: byte): string; 
You can make copy perform Right$ and Left$ as well by doing:
Copy(S, 1, Length) for left$ and 
Copy(S, Start, 255) for right$
Note: Start and Length are the byte positions of your starting point, get these with Pos().
Here are some functions I wrote that come in handy for me. Way down at the bottom is a trim() function that you can modify into TrimRight$ and TrimLeft$. Also, they all take pascal style strings, but you can modify them to easily null terminated.



--------------------------------------------------------------------------------

const
   BlackSpace = [#33..#126];

{
   squish() returns a string with all whitespace not inside single
quotes deleted.
}
function squish(const Search: string): string;
var
   Index: byte;
   InString: boolean;
begin
   InString:=False;
   Result:='';
   for Index:=1 to Length(Search) do
   begin
      if InString or (Search[Index] in BlackSpace) then
         AppendStr(Result, Search[Index]);
      InString:=((Search[Index] = '''') and (Search[Index - 1] <> '\'))
            xor InString;
   end;
end;

{
   before() returns everything before the first occurance of
Find in Search. If Find does not occur in Search, Search is
returned.
}
function before(const Search, Find: string): string;
var
   index: byte;
begin
   index:=Pos(Find, Search);
   if index = 0 then
      Result:=Search
   else
      Result:=Copy(Search, 1, index - 1);
end;

{
   after() returns everything after the first occurance of
Find in Search. If Find does not occur in Search, a null
string is returned.
}
function after(const Search, Find: string): string;
var
   index: byte;
begin
   index:=Pos(Find, Search);
   if index = 0 then
      Result:=''
   else
      Result:=Copy(Search, index + Length(Find), 255);
end;

{
   RPos() returns the index of the first character of the last
occurance of Find in Search. Returns 0 if Find does not occur
in Search. Like Pos() but searches in reverse.
}
function RPos(const Find, Search: string): byte;
var
   FindPtr, SearchPtr, TempPtr: PChar;
begin
   FindPtr:=StrAlloc(Length(Find)+1);
   SearchPtr:=StrAlloc(Length(Search)+1);
   StrPCopy(FindPtr,Find);
   StrPCopy(SearchPtr,Search);
   Result:=0;
   repeat
      TempPtr:=StrRScan(SearchPtr, FindPtr^);
      if TempPtr <> nil then
         if (StrLComp(TempPtr, FindPtr, Length(Find)) = 0) then
         begin
            Result:=TempPtr - SearchPtr + 1;
            TempPtr:=nil;
         end
         else
            TempPtr:=#0;
   until TempPtr = nil;
end;

{
   inside() returns the string between the most inside nested
Front ... Back pair.
}
function inside(const Search, Front, Back: string): string;
var
   Index, Len: byte;
begin
   Index:=RPos(Front, before(Search, Back));
   Len:=Pos(Back, Search);
   if (Index > 0) and (Len > 0) then
      Result:=Copy(Search, Index + 1, Len - (Index + 1))
   else
      Result:='';
end;

{
   leftside() returns what is to the left of inside() or Search.
}
function leftside(const Search, Front, Back: string): string;
begin
   Result:=before(Search, Front + inside(Search, Front, Back) + Back);
end;

{
   rightside() returns what is to the right of inside() or Null.
}
function rightside(const Search, Front, Back: string): string;
begin
   Result:=after(Search, Front + inside(Search, Front, Back) + Back);
end;

{
   trim() returns a string with all right and left whitespace removed.
}
function trim(const Search: string): string;
var
   Index: byte;
begin
   Index:=1;
   while (Index <= Length(Search)) and not (Search[Index] in BlackSpace) do
      Index:=Index + 1;
   Result:=Copy(Search, Index, 255);
   Index:=Length(Result);
   while (Index > 0) and not (Result[Index] in BlackSpace) do
      Index:=Index - 1;
   Result:=Copy(Result, 1, Index);
end;

