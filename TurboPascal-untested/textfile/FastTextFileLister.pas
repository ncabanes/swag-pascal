(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0072.PAS
  Description: Fast Text file lister
  Author: GARY C. KING
  Date: 02-21-96  21:03
*)

uses Crt;

const
  Max_line=80;
  max_row=750;
var
  file_name : text;
  name : string[12];
  arr : array[1..max_row] of string[max_line];
  max : integer;
  line : integer;
  the_end : boolean;

procedure display(a : integer);
var j : integer;
begin
  ClrScr;
  j:=a;
  while (j<a+23) and (j<max) do
    begin
      writeln;
      write(arr[j]);
      j:=j+1;
    end
end;

procedure next;
begin
  if line+25<max then
    begin
      gotoXY(80,23);
      line:=line+1;
      writeln;
      write(arr[line+24]);
    end
end;

procedure previous;
begin
  if line>1 then
    begin
      line:=line-1;
      gotoXY(1,1);
      InsLine;
      write(arr[line]);
    end
end;

procedure Page_up;
begin
  if line>1 then
    begin
      line:=line-23;
      if line<1 then line:=1;
      display(line)
    end
end;

procedure page_down;
begin
  if line<max-23 then
    begin
      line:=line+23;
      if line>max-23 then line:=max-23;
      display(line)
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

writeln('-----------------------------------------------------------------------------');
  TextColor(LightGray);
  if ParamStr(1)='' then
    begin
      write('Input filename: ');
      readln(name);
    end
  else
    name:=ParamStr(1);
  Assign(file_name,name);
  reset(file_name);

  max:=1;
  while not eof(file_name) do
    begin
      readln(file_name,arr[max]);
      max:=max+1
    end;
  TextBackground(White);
  TextColor(Black);

  GotoXY(1,1);
  ClrEol;
  write('Text View  |  No. of lines: ':52,max);
  GotoXY(1,25);
  ClrEol;
  write('File: ',name);
  TextBackground(Blue);
  TextColor(LightGray);

  window(1,2,80,24);
  line:=1;
  display(line);
  the_end:=false;
  repeat
    case menu of
      1 : next;
      2 : previous;
      3 : page_down;
      4 : Page_up;
      0 : begin
            TextBackground(black);
            TextColor(lightgray);
            window(1,1,80,25);
            ClrScr;
            the_end:=true
          end
    end
  until the_end
end.










