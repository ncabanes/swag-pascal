{
DC>I have a little major problem... And offcourse I want YOU to help me!
DC>I want to write something that gives of a 8-letter word all the possible
DC>combinations. So that 'RDEPTRAO' gives 'PREDATOR'. I think it must be about
DC>256 combinations. I don't need a program that gives 'PREDATOR' directly, but
DC>just something that gives me all those possibilities.

Here is something that may help you a little. It works fine on my
PC with one small proviso. If you specify permutations of 8
objects taken 8 at a time (what you want ...) then the program
runs out of heap space. Try it will smaller numbers first - like
permutations of 5 objects taken 3 at a time. This will show you
how it works. You can then try to modify it so that it will not
run out of memory generating the 40320 permutations that you are
looking for.

  Program perms, written by Clive Moses. This program will
  generate all permutations of n objects, taken r at a time,
  memory allowing.

  Challenge: try to modify the program so that it will not
  guzzle massive amounts of memory generating its output.
}

program perms;

{ Program to generate permutations of n objects, taken m at a time.
  For test purposes: m <= n <= 8. The program, as implemented here,
  effectively uses a 'breadth-first' algorithm. If it could be changed
  to run in a 'depth-first' fashion, it would not be necessary to
  store all of the intermediate information used to create the
  permutations. A 'depth-first' algorithm might have to be recursive
  however.
}

uses  crt;

type  str8   = string[8];

      torec   = ^rec;

      rec  = record
        perm,
        left  : str8;
        next  : torec;
      end;

const objects : str8 = 'abcdefgh';

var   m, n    : integer;
      first   : torec;

procedure NewRec (var p : torec);
begin
  NEW (p);
  with p^ do
  begin
    perm := '';
    left := '';
    next := NIL;
  end;
end;

procedure PrintPerms (var first : torec);
var p     : torec;
    count : integer;
begin
  p := first;
  count := 0;
  while p<>NIL do
  begin
    if p^.perm <> ''
    then
       begin
         write (p^.perm:8);
         inc (count);
       end;
    p := p^.next;
  end;
  writeln;
  writeln;
  writeln (count,' records printed.');
end;

procedure MakePerms (m, n : integer; var first : torec);
var i,
    level : integer;
    p,
    p2,
    temp  : torec;
begin
  writeln ('Permutations of ',n,' objects taken ',m,' at a time ...');
  writeln;
  if m <= n
  then
     begin
       level := 0;
       NewRec (first);
       first^.left := copy (objects, 1, n);
       while level < m do
       begin
         p2 := NIL;
         temp := NIL;
         p := first;
         NewRec (p2);
         while p <> NIL do
         begin
           for i := 1 to length(p^.left) do
           begin
             if temp=NIL then temp := p2;
             p2^.perm := p^.perm + p^.left[i];
             p2^.left := p^.left;
             delete (p2^.left, i, 1);
             NewRec (p2^.next);
             p2 := p2^.next;
           end;
           p := p^.next;
         end;
         inc (level);
         p := first;
         while p<>NIL do
         begin
           p2 := p^.next;
           dispose (p);
           p := p2;
         end;
         first := temp;
       end
     end;
end;

begin { Main Program }
  clrscr;
  first := NIL;
  writeln ('Memory available = ',memavail);
  writeln;
  repeat
    write ('Total number of objects: ');
    readln (n);
  until n in [1..8];
  repeat
    write ('Size of permutation:   ');
    readln (m);
  until m in [1..n];
  MakePerms (m, n, first);
  PrintPerms (first);
  writeln;
  writeln ('Memory available = ',memavail);
end.
