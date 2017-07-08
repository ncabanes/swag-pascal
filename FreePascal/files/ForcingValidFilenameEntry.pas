(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0074.PAS
  Description: Forcing Valid Filename Entry
  Author: DAVID HOWORTH
  Date: 05-26-95  23:07
*)

{
Here is a routine I used.  It forces entry of a proper filename,
not quite what you're looking for, but close:
}

uses
  Crt;

const
  OKFNameChars = ['A'..'Z','a'..'z','0'..'9','$','%','''',
                  '-','@','{','}','~','`','!','#','(',')','&'];

procedure Backspace;
begin
  gotoxy(wherex-1,1);write(' ');gotoxy(wherex-1,1);
end;

function GetFileName(Prompt : string) : string;
var
  OKCharSet : set of char;
  ch : char;
  Done : boolean;
  Name : string;
  len : byte absolute Name;
begin
  OKCharSet := OKFNameChars + ['.',#8,#13,#27];
  write(Prompt);
  Done := false;
  Name := '';
  repeat
    repeat
      ch := upcase(readkey);
    until (ch in OKCharSet);
    case ch of
      #8 : if len > 0 then begin
             Backspace;
             dec(len);
           end;
      #13 : Done := true;
      #27 : begin
              while len > 0 do begin
                Backspace;
                dec(len);
              end;
              Done := true;
            end;
      '.' : if (len > 0)
             and (pos('.',Name) = 0) then begin
              write('.');
              Name := Name + '.';
            end;
      else if ((pos('.',Name) = 0) and (len < 8))
           or (len - pos('.',Name) < 3) then begin
             Name := Name + ch;
             write(ch);
           end;
    end; { case }
  until Done;
  writeln;
  GetFileName := Name;
end;

{ test follows }
var
  fname : string;

begin
  clrscr;
  repeat
    fname := GetFileName('Enter file name: ');
  until fname = '';
end.
