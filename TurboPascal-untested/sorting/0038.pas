(*
IAN LIN

> Can someone show me an example of how to properly dispose of a linked list?

I was just as bad when I started in February. :) Anyhow, use mark and
release. They're 2 new things I've discovered and love much more than
dispose or freemem. Use MARK(ram) where VAR RAM:POINTER {an untyped
pointer}. This will save the state of the heap. NOW, when you are done,
do this: release(ram) and it's back the way it was. No freemem, no dispose,
just RELEASE! I REALLY love it. :) Need to allocate and deallocate some
times in between the beginning and the end? Use more untyped pointers (eg.
RAM2, RAM3, etc.) and you get the picture. Gotta love it. :) Look for a
message from me in here about linked list sorting. I wrote an entire
program that does this (to replace DOS's sort. Mine's faster and can use
more than 64k RAM). Here it is. Some of it is maybe too hard for you but
then you can ignore that part and just see how I used mark and release.
*)

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X-}
{$M 8192, 0, 655360}

type
  pstring = ^string;
  prec    = ^rec;

  rec     = record
    s : pstring;
    n : prec;
  end;

Var
  dash   : byte;
  err,
  max, c : word;
  list,
  list2,
  node,
  node2  : prec;
  ram,
  ram2,
  ram3   : pointer;
  tf     : text;
  f      : file;

procedure dodash;
begin
  case dash of
    1 : write('-');
    2 : write('\');
    3 : write('|');
    4 : write('/');
  end;
  write(#8, ' ', #8);
  dash := dash mod 4 + 1;
end;

procedure TheEnd;
begin
  writeln('Assassin Technologies, NetRunner.');
  halt(err);
end;

procedure showhelp;
begin
  writeln('Heavy duty sorter. Syntax: NSORT <INFILE> <OUTFILE>.');
  writeln('Exit codes: 0-normal; 1-not enough RAM; 2-can''t open infile;');
  writeln('3-outfile can''t be created');
  halt;
end;

procedure noram;
begin
  release(ram);
  assign(f, paramstr(1));
  writeln('Not enough RAM. ', memavail div 1024, 'k; file: ', filesize(f));
  err := 1;
  halt;
end;

procedure newnode(var pntr : prec);
begin
  if sizeof(prec) > maxavail then
  begin
    close(tf);
    noram;
  end;
  new(pntr);
  dodash;
  pntr^.n := nil;
end;

procedure getln(var ln : pstring);
var
  line : string;
  size : word;
begin
  readln(tf, line);
  size := succ(length(line));
  if size > maxavail then
    noram;
  getmem(ln, size);
  move(line, ln^, succ(length(line)));
  dodash;
end;

begin
  err := 0;
  exitproc := @TheEnd;
  if paramcount = 0 then
    showhelp;
  assign(tf, paramstr(1));
  reset(tf);

  if ioresult <> 0 then
  begin
    writeln('Can''t open "', paramstr(1), '".');
    err := 2;
    halt;
  end;

  mark(ram);
  newnode(list);

  if not eof(tf) then
  begin
    getln(list^.s);
    node := list;

    while not eof(tf) do
    begin
      newnode(node^.n);
      node := node^.n;
      getln(node^.s);
    end;

    close(tf);
    newnode(list2);
    list2^.n := list;
    list := list^.n;
    list2^.n^.n := nil;

    while list <> nil do
    begin
      dodash;
      node  := list;
      list  := list^.n;
      node2 := list2;

      while (node2^.n <> nil) and (node^.s^ > node2^.n^.s^) do
        node2 := node2^.n;

      node^.n  := node2^.n;
      node2^.n := node;
      dodash;
    end;
    list := list2^.n;

    assign(tf, paramstr(2));
    rewrite(tf);
    if ioresult <> 0 then
    begin
      writeln('Can''t create "', paramstr(2), '"');
      err := 3;
    end;

    node := list;
    while node <> nil do
    begin
      writeln(tf, node^.s^);
      node := node^.n;
      dodash;
    end;
    writeln;
    close(tf);
    release(ram);
  end;
end.
