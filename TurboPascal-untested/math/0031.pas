Program PYTHAGOREAN_TRIPLES;
{written by Mark Lewis, April 1, 1990}
{developed and written in Turbo Pascal v3.0}

Const
  hicnt     = 100;
  ZERO      = 0;

Type
  PythagPtr = ^PythagRec;           {Pointer to find the Record}
  PythagRec = Record                {the Record we are storing}
    A : Real;
    B : Real;
    C : Real;
    total : Real;
    next : PythagPtr    {Pointer to next Record in line}
  end;

Var
  Root      : PythagPtr;            {the starting point}
  QUIT      : Boolean;
  ch        : Char;

Procedure listdispose(Var root : pythagptr);

Var
  holder : pythagptr;

begin
  if root <> nil then               {if we have Records in the list}
  Repeat                          {...}
    holder := root^.next;         {save location of next Record}
    dispose(root);                {remove this Record}
    root := holder;               {go to next Record}
  Until root = nil;               {Until they are all gone}
end;

Procedure findpythag(Var root : pythagptr);
Var
  x,y,z,stored : Integer;
  xy,zz,xx,yy  : Real;
  abandon      : Boolean;
  workrec      : pythagrec;
  last,current : pythagptr;

begin
  stored := zero;                   {init count at ZERO}
  For z := 1 to hicnt do            {start loop 3}
  begin
    zz := sqr(z);                 {square loop counter}
    if zz < zero then
      zz := 65536.0 + zz;  {twiddle For negatives}
    For y := 1 to hicnt do        {start loop 2}
    begin
      yy := sqr(y);             {square loop counter}
      if yy < zero then
        yy := 65536.0 + yy;  {twiddle For negatives}
      For x := 1 to hicnt do    {start loop 1}
      begin
        abandon := False;     {keep this one}
        xx := sqr(x);         {square loop counter}
        xy := xx + yy;        {add sqr(loop2) and sqr(loop1)}
        if not ((xy <> zz) or ((xy = zz) and (xy = 1.0))) then
        begin
          With workrec do
          begin
            a := x;       {put them into our storage Record}
            b := y;
            c := z;
            total := zz;
          end;
          if root = nil then  {is this the first Record?}
          begin
            new(root);               {allocate space}
            workrec.next := nil;     {anchor the Record}
            root^ := workrec;        {store it}
            stored := succ(stored);  {how many found?}
          end
          else                {this is not the first Record}
          begin
            current := root;  {save where we are now}
            Repeat            {walk Records looking For dups}
              if (current^.total = workrec.total) then
                abandon := True; {is this one a dup?}{abandon it}
              last := current;  {save where we are}
              current := current^.next  {go to next Record}
            Until (current = nil) or abandon;
            if not abandon then {save this one?}
            begin
              {we're going to INSERT this Record into the}
              {line between the ones greater than and less}
              {than the A Var in the Record}
              {ie: 5,12,13 goes between 3,4,5 and 6,8,10}
              if root^.a > workrec.a then
              begin
                new(root);   {allocate mem For this one}
                workrec.next := last; {point to next rec}
                root^ := workrec;     {save this one}
                stored := succ(stored); {how many found?}
              end
              else  {insert between last^.next and current}
              begin
                new(last^.next);  {allocate memory}
                workrec.next := current; {point to current}
                last^.next^ := workrec; {save this one}
                stored := succ(stored); {how many found?}
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  Writeln('I have found and stored ',stored,' Pythagorean Triples.');
end;

Procedure showRecord(workrec : pythagrec);

begin
  With workrec do
  begin
    Writeln('A = ',a:6:0,'  ',sqr(a):6:0);
    Writeln('B = ',b:6:0,'  ',sqr(b):6:0,'  ',sqr(a)+sqr(b):6:0);
    Writeln('C = ',c:6:0,'  ',sqr(c):6:0,' <-^');
  end
end;

Procedure viewlist(root  : pythagptr);

Var
  i        : Integer;
  current  : pythagptr;

begin
  if root = nil then
  begin
    Writeln('<< Your list is empty! >>');
    Write('>> Press (CR) to continue: ');
    readln;
  end
  else
  begin
    Writeln('Viewing Records');
    current := root;
    While current <> nil do
    begin
      showRecord(current^);
      Write('Press (CR) to view next Record. . . ');
      readln;
      current := current^.next
    end;
  end
end;

begin
  Writeln('PYTHAGOREAN TRIPLES');
  Writeln('-------------------');
  Writeln;
  Writeln('Remember the formula For a Right Triangle?');
  Writeln('A squared + B squared = C squared');
  Writeln;
  Writeln('I call the set of numbers that fits this formula');
  Writeln('         Pythagorean Triples');
  Writeln;
  Writeln('This Program Uses a "brute force" method of finding all');
  Writeln('the Pythagorean Triples between 1 and 100');
  Writeln;
  root := nil;
  quit := False;
  Repeat
    Writeln('Command -> [F]ind, [V]iew, [D]ispose, [Q]uit ');
    readln(ch);
    Case ch of
      'q','Q' : quit := True;
      'f','F' : findpythag(root);
      'v','V' : viewlist(root);
      'd','D' : listdispose(root);
    end;
  Until quit;
  if root <> nil then
    listdispose(root);
  Writeln('Normal Program Termination');
end.

