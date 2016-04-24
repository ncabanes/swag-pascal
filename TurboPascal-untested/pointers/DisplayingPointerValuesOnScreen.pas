(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0031.PAS
  Description: Displaying Pointer Values on Screen
  Author: IAN LIN
  Date: 05-26-95  23:01
*)

{ Convert it to 2 words and then do it. You can do it like this; }
Type
 St4  = string[4];
 PRec = record
  Ofs, Seg: Word;
 end;

Var
 P:Pointer;
 P2:PRec absolute P;

Function Hexw(w:word):st4;
var s:st4; c:byte; n:array [1..2] of byte absolute w;
begin
 s:='';
 for c:=2 downto 1 do s:=s+hexid[n[c] shr 4]+hexid[n[c] and $f];
 hexw:=s;
end;

Begin
 Writeln('Pointer P is at address: ',P2.Seg,':',P2.Ofs,'.');
 writeln('In hex, that''s ',hexw(p2.seg),':',hexw(p2.ofs,'.');
End.
{
You can also use typecasting instead of absolute variables. To do this,
you would use PRec(p) instead of P2 in all places.

> am making an exitprocedure for runtime errors, but when I try to write
> the address, its not allowed. I triedto convert it to a word but no-go.
> Anyone, any ideas would be nicely taken.

It's not 1 word but 2. Word is 2 bytes, longint and pointer are 4. PRec
splits it into 2 fields each of size Word.
}

