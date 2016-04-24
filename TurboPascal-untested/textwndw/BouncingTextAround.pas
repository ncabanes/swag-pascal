(*
  Category: SWAG Title: TEXT WINDOWING ROUTINES
  Original name: 0029.PAS
  Description: Bouncing Text Around
  Author: RODRIGO MOREIRA SILVEIRA
  Date: 08-30-96  09:36
*)

Program rotatingtxt;

uses crt;

const txt = 'IT IS TEXT KICKING!';

var
 i,o   : Byte;
 ii,oo : boolean;

Begin
  o := 1;
  i := 1;
  textmode(co80);
  Asm MOV ax,$0100; MOV cx,$2607; INT $10; end;
  repeat
      if i >= 80-length(txt) then ii := true;
      if ii Then i := i-2;
      if i <= 1 then ii := false;
      if o >= 25 then oo := true;
      if oo Then o := o-2;
      if o <= 1 then oo := false;
      inc(o,1);
      inc(i,1);
      gotoxy(i,o);
      write(txt);
      delay(50);
      clrscr;
  until keypressed;
  gotoxy(1,1);
  clrscr;
  writeln('No more ideas, it''s over!');
  Writeln('Coded by ZεU$');
  write('E-Mail me at arlindo@solar.com.br');
  Asm MOV ax,$0100; MOV cx,$0506; INT $10; end;
end.

