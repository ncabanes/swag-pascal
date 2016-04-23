
program du_kivuni;
uses crt;
type pelement=^element;
          element=record
             info:integer;
             r,l:pelement;
             end;
var head:pelement;sp:char;val:integer;
procedure init (var head:pelement);
begin
  new (head);
  writeln('Type value.');
  readln(head^.info);
  head^.l:=nil;
  head^.r:=nil;
end;
procedure insert (var head:pelement;val:integer);
var t,p:pelement;
begin
new(t);
new(p);
write('Type value: ');
readln(t^.info);
if t^.info >= head^.info then
begin
p:=head;
if p^.r<>nil then
 begin
   while (p^.r<>nil) and (p^.info<t^.info) do
    begin
     if p^.r^.info>=t^.info then
      begin
       t^.l:=p;
       p^.r^.l:=t;
       t^.r:=p^.r;
       p^.r:=t;
      end;
     p:=p^.r;
    end;
 end;
if p^.r=nil then begin
p^.r:=t;
t^.l:=p;
t^.r:=nil;
end;
end;
if t^.info < head^.info then
begin
p:=head;
if p^.l<>nil then
 begin
   while (p^.l<>nil) and (p^.info>t^.info) do
    begin
     if p^.l^.info<=t^.info then
      begin
       t^.r:=p;
       p^.l^.r:=t;
       t^.l:=p^.l;
       p^.l:=t;
      end;
     p:=p^.l;
    end;
 end;
if p^.l=nil then begin
p^.l:=t;
t^.r:=p;
t^.l:=nil;
end;
end;
end;
procedure print (var head:pelement);
var p:pelement;
begin
 p:=head;
 if (head^.r=nil) and (head^.l=nil) then write(head^.info)
  else begin
        while p^.l<>nil do p:=p^.l;
        while p^.r<>nil do
         begin
            write(p^.info:3);
            p:=p^.r;
         end;
       writeln(p^.info:3);
      end;
end;
begin
clrscr;
init (head);
writeln('(I)nsert (P)rint (Q)uit ');
readln(sp);
while sp<>'q' do begin
case sp of
     'i':insert(head,val);
     'p':print(head);
     end;
     writeln;
     writeln('(I)nsert (P)rint (Q)uit ');
     readln(sp);
  end;
end.
