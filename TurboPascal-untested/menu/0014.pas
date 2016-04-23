program asci_puldown;

uses crt;

var
  x,y,p    :integer;
  ay       :byte;
  ch       :char;


procedure ascihor(x,y :byte;aantal :integer;character,color :byte);

begin
  textcolor(color);gotoxy(x,y);
  for p :=1 to aantal do write(chr(character));
end;


procedure asci_tekst(x,y :byte;str :string;color,back_color : Byte);

begin
  textbackground(back_color);
  textcolor(color);
  gotoxy(x,y);write(str);
  textbackground(0);
end;


procedure menu;

const
  afspr :array[1..6] of string[12] =
          ('INVOER','WIJZIGEN','OVERZICHT','SORTEREN','PRINTEN','EXIT');

label start;

begin
  textcolor(3);
  gotoxy(26,6);write('┌');write('─────────────');write('┐');
  for p :=7 to 12 do begin
    gotoxy(26,p);write('│');
    gotoxy(40,p);write('│');
  end;
  gotoxy(26,13);write('└');write('─────────────');write('┘');

  for y :=1 to 6 do asci_tekst(28,y+6,afspr[y],6,0);
  ascihor(27,7,13,219,7);asci_tekst(28,7,afspr[1],0,7);

  ay :=7;

  start:

  repeat
    ch :=readkey;
    if ch =#80 then begin
      ascihor(27,ay,13,219,0);asci_tekst(28,ay,afspr[ay-6],6,0);
      inc(ay);if ay =13 then ay :=7;
      ascihor(27,ay,13,219,7);asci_tekst(28,ay,afspr[ay-6],0,7);
    end;
    if ch =#72 then begin
      ascihor(27,ay,13,219,0);asci_tekst(28,ay,afspr[ay-6],6,0);
      dec(ay);if ay =6 then ay :=12;
      ascihor(27,ay,13,219,7);asci_tekst(28,ay,afspr[ay-6],0,7);
    end;
  until ch in[#13];

  if ay =7 then begin end;
  if ay =8 then begin end;
  if ay =9 then begin end;
  if ay =10 then begin end;
  if ay =11 then begin end;
  if ay =12 then halt;

  goto start;
end;

begin
  clrscr;
  menu;
end.