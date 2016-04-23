program Pokaz;
uses Crt;

const
  Max_line=80;
  max_row=700;

var
  plik : text;
  nazwa : string[12];
  tablica : array[1..max_row] of string[max_line];
  max : integer;
  linia : integer;
  koniec : boolean;

procedure Wyswietl(a : integer);
var j : integer;
begin
  ClrScr;
  j:=a;
  while (j<a+23) and (j<max) do
    begin
      writeln;
      write(tablica[j]);
      j:=j+1;
    end
end;

procedure Nastepny;
begin
  if linia+25<max then
    begin
      gotoXY(80,23);
      linia:=linia+1;
      writeln;
      write(tablica[linia+24]);
    end
end;

procedure Poprzedni;
begin
  if linia>1 then
    begin
      linia:=linia-1;
      gotoXY(1,1);
      InsLine;
      write(tablica[linia]);
    end
end;

procedure Strona_gora;
begin
  if linia>1 then
    begin
      linia:=linia-23;
      if linia<1 then linia:=1;
      Wyswietl(linia)
    end
end;

procedure Strona_dol;
begin
  if linia<max-23 then
    begin
      linia:=linia+23;
      if linia>max-23 then linia:=max-23;
      Wyswietl(linia)
    end
end;

function Menu : integer;
var znak : char;
begin
  repeat znak:=Readkey;
  until  znak in
  [chr(80),chr(72),chr(73),chr(81),chr(27)];

  if ord(znak)=27 then menu:=0
  else if ord(znak)=80 then menu:=1
  else if ord(znak)=72 then menu:=2
  else if ord(znak)=81 then menu:=3
  else if ord(znak)=73 then menu:=4
end;

begin
  ClrScr;
  GotoXY(1,24);
  TextColor(LightBlue);

writeln('─────────────────────────────────────────────────────────────────────────────');
TextColor(LightGray);
if ParamStr(1)='' then
    begin
      write('Podaj nazwe pliku: ');
      readln(nazwa);
    end
  else
    nazwa:=ParamStr(1);
  Assign(plik,nazwa);
  reset(plik);

  max:=1;
  while not eof(plik) do
    begin
      readln(plik,tablica[max]);
      max:=max+1
    end;
  TextBackground(White);
  TextColor(Black);

  GotoXY(1,1);
  ClrEol;
  write('W & W Obejrzyj','Liczba linii: ':60,max-1);
  GotoXY(1,25);
  ClrEol;
  write('Plik: ',nazwa,'@K. Walczak':65);
  TextBackground(Blue);
  TextColor(LightGray);

  window(1,2,80,24);
  linia:=1;
  wyswietl(linia);
  koniec:=false;
  repeat
    case menu of
      1 : Nastepny;
      2 : Poprzedni;
      3 : strona_dol;
      4 : strona_gora;
      0 : begin
            TextBackground(black);
            TextColor(lightgray);
            window(1,1,80,25);
            ClrScr;
            koniec:=true
          end
    end
  until koniec
end.
