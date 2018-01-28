(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0047.PAS
  Description: RIP (BASE 36)
  Author: EDWIN GROOTHUIS
  Date: 05-25-94  08:21
*)

{
 AE> numbersystem... When you want to create something in RIP you
 AE> first need to write some calculator to translate normal numbers
 AE> to RIP codes...

It's not that difficult, you know how to convert hex -> normal and
normal -> hex? Well, then you also can convert mega -> normal and normal
-> mega

little idea:
}

function word2mega(w:word):string;
const    table:array[0..35] of char='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var      s:string;
begin
  s:='';
  while w>0 do
  begin
    s:=table[w mod 36]+s;
    w:=w div 36;
  end;
  while length(s)<4 do s:='0'+s;
  word2mega:=s;
end;

function mega2word(s:string):word;
var      w:word;
begin
  w:=0;
  if length(s)<5 then
    while s<>'' do
    begin
      if s[1]>'9' then
        w:=w*36+ord(s[1])-ord('A')+10
      else
        w:=w*36+ord(s[1])-ord('0');
      delete(s,1,1);
    end;
  mega2word:=w;
end;


var    n:word;
        s:string;
        c: byte;
begin
  s:=paramstr(1);
  for n:=1 to length(s) do
    s[n]:=upcase(s[n]);
  writeln('mega2word: ',mega2word(s));
  val(s,n,c);
  writeln('word2mega: ',word2mega(n));
end.
{
converts a meganum to a word and a word to a meganum in one program!
(Just one program so I don't have to think in which way it has to be
converted)

mega 12<cr> gives
mega2word: 38
word2mega: 0C

mega 1C<cr> gives
mega2word: 48
word2mega: 00
}
