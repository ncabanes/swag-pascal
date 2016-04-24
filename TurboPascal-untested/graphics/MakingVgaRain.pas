(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0079.PAS
  Description: Making VGA Rain
  Author: DON LABARRE
  Date: 02-03-94  16:18
*)

{
It's not often that I post anything but since I started getting into it I
figured I'd post something worth while. Heres some code I wrote to produce some
"blood" rain. It isn't much but it's cool to look at :)

{This code is release freely to anyone that wants it. I couldn't care less
 what you do with it. It is being used in my demo so if I see it in yours
 i will find you and kill you. Nemesis 1994}

program rain;
var p:integer;

function keypressed : boolean; assembler; asm
  mov ah,0bh; int 21h; and al,0feh; end;

Procedure RotatePal;
Var a:Word;
Begin
  inc(p);
  port[968]:=35;
  a:=100;

  while port[$3da] and 8 <> 0 do;
  while port[$3da] and 8 = 0 do;

  while a>1 do
  begin
    port[969]:=1-((a+p) and 60);
    port[969]:=0;
    {If you want a better palette selection and more play then remove
     the above line and replace with the one below. It will allow you
     to get to the blues and greens and yellows but I made mine red so
     did not require those}
    {port[969]:=1-((a+p) and 60);}
    port[969]:=1-((a+p) and 65);
    dec(a);
    end;
end;

Procedure makerain;
Var
  x,y,c,d:word;
begin
  d:=1;
  randomize;
  for x:=0 to 320 do
  Begin
    c:=random(65);
    for y:=0 to 200 do
    Begin
      if c>64 then c:=1;
      mem[$a000:x+320*y]:=c+35;
      inc(c,d);
    end;
    d:=random(5)+1;
  end;
end;


begin
asm
  mov ax,$0013
  int 10h
  end;
makerain;
repeat
RotatePal;
until keypressed;
asm
  mov ax,$0002
  int 10h
end;
end.


