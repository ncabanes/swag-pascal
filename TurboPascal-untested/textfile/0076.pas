unit textfile;

INTERFACE

function  numlines1(n:string):longint;
function  numlines2(var f:text):longint;

IMPLEMENTATION

function numlines1(n:string):longint;
var
  f:text;
  c:longint;
begin
  numlines1:=-1;
  assign(f,n);
  {$i-} reset(f); {$i+}
  if(ioresult<>0)then exit;
  c:=0;
  while not eof(f)do
  begin
    readln(f);
    inc(c);
  end;
  numlines1:=c;
  close(f);
end;

function numlines2(var f:text):longint;
var
  c:longint;
begin
  numlines2:=-1;
  {$i-} close(f); {$i+}
  if(ioresult<>0)then ;
  {$i-} reset(f); {$i+}
  if(ioresult<>0)then exit;
  c:=0;
  while not eof(f)do
  begin
    readln(f);
    inc(c);
  end;
  numlines2:=c;
  close(f);
end;

end.