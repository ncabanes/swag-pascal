(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0101.PAS
  Description: More on PERCENT.
  Author: BRIAN PETERSEN
  Date: 11-22-95  13:29
*)

{
function percent(p,t:longint):longint;
begin
  percent:=trunc(100*(p/t));
end;

There you go!  :)  p is the partial value, t is the total value, as in...

percent(50,100) = 50%

If you want it to return a string instead of a longint, do it like this:
}
function percent(p,t:longint):string;
var s:string; l:longint;
begin
  l:=trunc(100*(p/t));
  str(l,s);
  percent:=s+'%';
end;

begin
  WriteLn('67 is ' + percent(67, 120) + ' of 120');
end.
