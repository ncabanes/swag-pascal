(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0079.PAS
  Description: Changing from Base 10 to Base 2
  Author: MATTHEW BUAS
  Date: 08-30-96  09:35
*)

program Base_Change;
 
uses crt;
var num,base: integer;
    mult2,emult2,emult2old,num2:integer;
    fl: integer;
 
{------------------------------------------------}
function getMult (number:integer): integer;
var cur,flag:integer;
begin
if (number >= 2) then begin
  cur:=2;
 
  if (cur < number) and ((cur * 2) <= number) then begin
   repeat
         cur:=cur * 2;
   until ((cur*2) > number);
  end;
 
  getMult:=cur;
 
end
else getMult:=1;
 
end;
 
{------------------------------------------------}
{log base 2 function}
function ex (number:integer): integer;
var flag1:integer;
begin
 
if (number >= 2) then begin
 flag1:=0;
 repeat
      number:=number div 2;
      flag1:=flag1+1;
 until (number < 2);
 
 ex:=flag1;
end {if}
else ex:=0;
 
 
end;
 
{------------------------------------------------}
begin
 
clrscr;
textcolor(15);
writeln('Base Change');
normvideo;
writeln;
write('Number: ');
readln(num);
{
write('Base (2-10): ');
readln(base);
}
 
write('Binary: ');
fl:=0;
repeat
      mult2:=getMult(num);
{      writeln(mult2);}
      emult2:=ex(mult2);
      num:=num-mult2;
      if (fl=0) then begin
         write('1');
      end
      else begin
           repeat
              if (emult2old-emult2 > 1) then begin
                 write('0');
                 emult2old:=emult2old-1;
              end;
           until (emult2old-emult2=1);
           write('1');
      end;
      emult2old:=emult2;
      fl:=fl+1;

until (num=0);

if (emult2 <> 0) then begin
   repeat
         write('0');
         emult2:=emult2-1;
   until (emult2=0);
end;
writeln;

end.

