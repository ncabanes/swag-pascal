program factor;

uses
   crt;

type
   list = ^ node;
   node = record
      data:integer;
      next:list;
   end;

var
   squrl, squll,
   nonerl, nonell:list;

procedure push(var head:list; item:integer);
var
   temp:list;
begin
   new(temp);
   temp^.data:= item;
   temp^.next:= head;
   head:= temp;
end;

function x(l:list; n:integer):integer;
var
   i:integer;
begin
   for i:= 1 to n-1 do
      l:= l^.next;
   x:= l^.data;
end;

function dimL(l:list):integer;
var
   count:integer;
begin
   count:= 0;
   while l <> nil do
      begin
         l:= l^.next;
         count:= count + 1;
      end;
   dimL:= count;
end;

procedure show(l:list);
begin
   while l <> nil do
      begin
         write(l^.data, '  ');
         l:= l^.next;
      end;
   writeln;
end;

procedure negate(var l:list);
var
   temp:list;
begin
   temp:= l;
   while temp <> nil do
      begin
         temp^. data:= -temp^.data;
         temp:= temp^.next;
      end;
end;

procedure display(a1, b1, a2, b2:integer);
begin
   writeln('(', a1, 'x + ', b1, ')(', a2, 'x + ', b2, ')');
end;

procedure getfactors(num:integer; var list1, list2:list);
var
   i:integer;
   test:integer;
   done:boolean;
begin
   if num > 0 then
      test:= 1
   else
      test:= num;
   repeat
      if num / test = num div test then
         begin
            push(list1, test);
            push(list2, num div test);
         end;
      test:= test + 1;
      if test = 0 then
         test:= 1;
   until abs(test) > abs(num);
end;

procedure cleanup(var list1, list2:list);
begin
   list1:= nil;
   list2:= nil;
end;

procedure geti(a1, a2, one:integer; var b:integer);
var
   i:integer;
begin
   for i:= 1 to dimL(nonerl) do
      if a1 * x(nonell, i) + a2 * x(nonerl, i) = one then
         b:= i;
end;


procedure doit;
var
   squ,
   one,
   none:integer;
   i, j:integer;
   a, b, c:integer;
   solved:boolean;
begin
   write('A: ');
   readln(squ);
   write('B: ');
   readln(one);
   write('C: ');
   readln(none);
   solved:= false;
   cleanup(squrl, squll);
   getfactors(squ, squrl, squll);
   cleanup(nonerl, nonell);
   getfactors(none, nonerl, nonell);
   for j:= 1 to diml(squrl) do
      for i:= 1 to diml(nonerl) do
         begin
            a:= x(squrl, j) * x(nonerl, i);
            c:= x(squll, j) * x(nonell, i);
            {writeln('A = ', a, ' C = ', c); readln;}
            if (a = squ) and (c = none) then
               begin
                  b:= i;
                  {writeln('A1 = ', x(squrl, j), ' A2 = ', x(squll, j));}
                  if one < 0 then
                     begin
                        negate(nonerl); negate(nonell);
                     end;
                  geti(x(squrl, j), x(squll, j), one, b);
                  {writeln('B = ', x(squrl, j) * x(nonell, b) + x(squll, j) * x(nonerl, b));}
     {FOIL check} if (c = x(nonerl, b) * x(nonell, b)) and
                  (one = x(squrl, j) * x(nonell, b) + x(squll, j) * x(nonerl, b)) then
                     begin
                        display(x(squrl, j), x(nonerl, b), x(squll, j), x(nonell, b));
                        solved:= true;
                     end;
               end;
         end;
   if not solved then
      writeln('Does not factor.');
end;

begin
   clrscr;
   doit;
   {show(squrl); show(squll);
   show(nonerl); show(nonell);}
   while not keypressed do;
end.
