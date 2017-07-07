(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0052.PAS
  Description: Show Date/Time
  Author: TANSIN DARCOS
  Date: 02-28-95  09:58
*)

program dt;


uses Dos;
const
   id = 'Tansin A Darcos & Company, P O Box 70970, SW DC 20024-0970 ' +
        '"Ask about our software catalog."'+
        '░░▒▒▓▓██ In Stereo Where Available ██▓▓▒▒░░  '+
        'Stolen tagline: "Special favors come in 31 flavors... Pass ' +
        'the mints... I''m out of Life Savers."   Just don''t sue us '  +
        'if you use this. ';


var
  i, y, m, d, h, s, hund, dow : Word;
  ch : char;
  cc : string[2];

  procedure date;
  begin
  GetDate(y,m,d,dow);
  WriteLn(m:0, '/', d:0, '/', y:0);
  end;

  procedure time;
  begin
  GetTime(h,m,s,hund);
  WriteLn(h,':',m,':',s);
  end;

  procedure help;
  begin
  writeln('  Shows Date and / or time        [TDR]');
  writeln('DT [ dt | d | t | td | /? ] [>file.txt]');
  writeln('            dt - (or no arguments) Shows date, then time');
  writeln('            d  - show date only');
  writeln('            t  - show time');
  writeln('            td - show time then date');
  writeln('            /? - show this message');
  writeln('     >file.txt - optionally send output to file.txt');
  end;

begin
    cc := 'DT';
    if paramcount<>0 then
      cc := paramstr(1);
    for i := 1 to Length(cc) do
      cc[i] := UpCase(cc[i]);
    ch := cc[1];
    if cc = '/?' then
      help
    else
      if length(cc) = 1 then
        if ch = 'D' then
          date
        else
          time
      else
        if (cc = 'TD') then
          begin
             time;
             date
          end
       else
          begin
             date;
             time
          end
end.
