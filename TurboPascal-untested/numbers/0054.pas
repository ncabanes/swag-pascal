{
Here is another attempt. It will also work with any length string
and generates all permutations without running out of memory, by
searching in a depth-first fashion.
}

{$M 64000,0,655360}

program perms2;

uses  Crt;

type  str52 = string[52];

const objects : str52 = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

var   m, n,
      fw, level,
      nperline   : integer;
      p1, p2     : str52;
      nperms     : longint;

procedure p (var p1, p2 : str52; var level : integer);
var p1n, p2n  : str52;
    i, nlevel : integer;
begin
  if level < m
  then
     begin
       nlevel := level + 1;
       for i := 1 to length(p2) do
       begin
         p1n := p1 + p2[i];
         p2n := p2;
         delete (p2n, i, 1);
         p (p1n, p2n, nlevel);
       end;
     end
  else
     begin
       write (p1:fw);
       inc (nperms);
     end;
end;

begin
  repeat
    clrscr;
    repeat
      write ('How many objects altogether?  ');
      readln (n);
    until (n>=0) and (n<53);
    if n>0
    then
       begin
         repeat
           write ('How many in each permutation? ');
           readln (m);
         until (m>0) and (m<=n);
         writeln;
         case m of
           1      : fw := 2;    { 40 per line }
           2..3   : fw := 4;    { 20 per line }
           4      : fw := 5;    { 16 per line }
           5..7   : fw := 8;    { 10 per line }
           8..9   : fw := 10;   { 8 per line }
           10..15 : fw := 16;   { 5 per line }
           16..19 : fw := 20;   { 4 per line }
           20..39 : fw := 40;   { 2 per line }
           40..52 : fw := 80;   { 1 per line }
         end;
         nperline := 80 div fw;
         level := 0;
         p1 := '';
         p2 := copy (objects, 1, n);
         nperms := 0;
         p (p1, p2, level);
         if (nperms mod nperline) <> 0 then writeln;
         writeln;
         writeln (nperms,' Permutations generated.');
         readln;
       end;
  until n=0;
end.
{
This one is a little more elegant, and should also be a little
easier to decipher than the last one! Hope this will be of some
use to you!
}
