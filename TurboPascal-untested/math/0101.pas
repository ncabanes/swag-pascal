
function percent(p,t:longint):longint;
begin
  percent:=trunc(100*(p/t));
end;

There you go!  :)  p is the partial value, t is the total value, as in...

percent(50,100) = 50%

If you want it to return a string instead of a longint, do it like this:

function percent(p,t:longint):string;
var s:string; l:longint;
begin
  l:=trunc(100*(p/t));
  str(l,s);
  percent:=s+'%';
end;
