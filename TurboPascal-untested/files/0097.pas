
(*This is a short and rather unoptomized and well to be honest SLOPPY     *)
(*representation of hex viewing (not editing) what this program WILL      *)
(*do however is go in and suck out the readable text in an exe dat com    *)
(*or other hex file so you can take a look see at whats in em :)          *)
(* This is VERY basic and is just to show the basic concept..             *)

(*This code was written by George Slaterpryce A.K.A. Illogical Error      *)
(*you can use it freely i dont really care what you do with it            *)
(*but if you use the concept behind it or the code itself just drop me a  *)
(*line or two at rapter@aug.com i would appreciate it....    also         *)
(**)
(*The author of this code (George Slaterpryce) is not responsible for what*)
(*it does to software/hardware on your computer you use it at your own risk*)
(**)
(*p.s. but it works fine on my 386, 486, and p133 *)


program ReadFile;
uses crt;
var
  F: file of string;
  f2 : file of char;
  f3 : file of integer;
  f4 : text;
  strng: string;
  ch   : char;
  num, count  : integer;
  didit : boolean;

(*Do all my error notices*)
(****************************************************************************)
procedure notice (var didit : boolean);
   begin
   clrscr;
   writeln;
   writeln;
   writeln('P.G.T.F.R.U. ReadFile.exe');
   Writeln('Pascal Genorated Typed File Reader Utility by George Slaterpryce');
   writeln('(C) 1996 George Slaterpryce A.K.A. Illogical Error');
   Writeln('This utility is Freeware.');
   Writeln;
   writeln('Usage ReadFile /[S,C,#,T,?] <filename.dat>');
   textcolor(blue);write('               option');textcolor(green);write('      file name');
   writeln('');
   textcolor(7);
   writeln;
   writeln('Command line Parameters');
   writeln('/S   Reads file of strings');
   writeln('/C   Reads file of chars');
   writeln('/#   Reads file of Integers');
   writeln('/T   Reads Text Files');
   writeln('/?   This Help Screen');
   didit := true;
   end;


procedure notice1(var didit : boolean);
   begin
   clrscr;
   writeln;
   writeln;
   writeln('P.G.T.F.R.U. ReadFile.exe');
   Writeln('Pascal Genorated Typed File Reader Utility by George Slaterpryce');
   writeln('(C) 1996 George Slaterpryce A.K.A. Illogical Error');
   Writeln('This utility is Freeware.');
   Writeln;
   writeln('Usage ReadFile /[S,C,#,T,?] <filename.dat>');
   textcolor(17);write('               option');textcolor(green);write('      file name');
   writeln('');
   textcolor(7);
   writeln;
   writeln('Command line Parameters');
   writeln('/S   Reads file of strings');
   writeln('/C   Reads file of chars');
   writeln('/#   Reads file of Integers');
   writeln('/T   Reads Text Files');
   writeln('/?   This help screen');
   didit := true;
   end;

procedure notice2(var didit : boolean);
   begin
   clrscr;
   writeln;
   writeln;
   writeln('P.G.T.F.R.U. ReadFile.exe');
   Writeln('Pascal Genorated Typed File Reader Utility by George Slaterpryce');
   writeln('(C) 1996 George Slaterpryce A.K.A. Illogical Error');
   Writeln('This utility is Freeware.');
   Writeln;
   writeln('Usage ReadFile /[S,C,#,T,?] <filename.dat>');
   textcolor(blue);write('               option');textcolor(18);write('      file name');
   writeln('');
   textcolor(7);
   writeln;
   writeln('Command line Parameters');
   writeln('/S   Reads file of strings');
   writeln('/C   Reads file of chars');
   writeln('/#   Reads file of Integers');
   writeln('/T   Reads Text Files');
   writeln('/?   This Help Screen');
   didit := (true);
   end;

procedure notice3;
   begin
   clrscr;
   writeln;
   writeln;
   writeln('P.G.T.F.R.U. ReadFile.exe');
   Writeln('Pascal Genorated Typed File Reader Utility by George Slaterpryce');
   writeln('(C) 1996 George Slaterpryce A.K.A. Illogical Error');
   Writeln('This utility is Freeware.');
   Writeln;
   writeln('Usage ReadFile /[S,C,#,T,?] <filename.dat>');
   textcolor(17);write('               option');textcolor(green);write('      file name');
   writeln('');
   textcolor(7);
   writeln;
   writeln('Command line Parameters');
   writeln('/S   Reads file of strings');
   writeln('/C   Reads file of chars');
   writeln('/#   Reads file of Integers');
   writeln('/T   Reads Text Files');
   writeln('/?   This help screen');
   end;

(***************************************************************************)


begin
count := 0; (*initialize all variables*)
clrscr;
didit := false;
clrscr;


(*Start our Hex viewing or Binary viewing*)
    IF paramstr(1) = '/h' then
        begin
      if paramstr(2) = '' then notice2(didit);   (*See if the user typed*)
      if paramstr(2) <> '' then           (*a file name if and they didnt*)
      begin                               (*tell them*)
      Assign(F2, paramstr(2));            (*if they did go on with the *)
      Reset(F2);                          (*function*)
      writeln;
      writeln;
      while not Eof(F2) do
      begin
      Read(F2, ch);
      if ch > char(31) then          (*throw out all the "trash" chars*)
      begin                          (* (the higher ended ascii codes and*)
      if ch < char(127) then         (* some of the lower ones to make it*)
                                     (*into more readable code*)
      begin
      IF count = 1500 then (*this is how many characters we can show on a *)
      begin;               (*screen at one time well actually you can show*)
      writeln;             (*2000 characters at a time(on a 80x25 standard*)
      writeln;             (*screen but 1500 gives you a little play room *)
      writeln('pause');
      readkey;
      writeln;
      writeln;
      clrscr;
      end;
      count := count + 1;
      Write(Ch);
      end;
      end;
    end;
    close(F2);
    didit := true;
  end;
  end;

(*end of hex/binary viewing*)
(***************************************************************************)


(*From here on down i added on some features that you could use to make*)
(*a more specialized view simple crup really :) but hey what the hell *)


    (* this little function here is to eleminate a rather stupid bug i had
    when the user typed nothing after fileread *)
    IF paramstr(1) = '' then
    begin
    assign(F, 'Error.txt');
    rewrite(F);
    close(F);
    notice3;
    end;
    (*******************************************)

    IF paramstr(1) = '/S' then
    begin
    if paramstr(2) = '' then notice2(didit);
    if paramstr(2) <> '' then
    begin
    Assign(F, paramstr(2));
    Reset(F);
    while not Eof(F) do
    begin
      Read(F, strng);
      Write(strng);
      writeln;
    end;
    close(F);
   end;
   didit := true;
   end;

  IF paramstr(1) = '/s' then
  begin
  if paramstr(2) = '' then notice2(didit);
  if paramstr(2) <> '' then
  begin
    Assign(F, paramstr(2));
    Reset(F);
    while not Eof(F) do
    begin
      Read(F, strng);
      Write(strng);
      writeln;
    end;
    close(F);
    didit := true;
  end;
  end;

   IF paramstr(1) = '/C' then
    begin
    if paramstr(2) = '' then notice2(didit);
    if paramstr(2) <> '' then
    begin
    Assign(F2, paramstr(2));
    Reset(F2);
    while not Eof(F2) do
    begin
      Read(F2, ch);
       if ch = char(7) then ch := char(255);
      Write(Ch);
      end;
    close(F2);
    didit := true;
   end;
   end;

    IF paramstr(1) = '/c' then
     begin
     if paramstr(2) = '' then notice2(didit);
     if paramstr(2) <> '' then
    begin
    Assign(F2, paramstr(2));
    Reset(F2);
    while not Eof(F2) do
    begin
      Read(F2, ch);
      if ch = char(7) then ch := char(255);
      Write(Ch);
    end;
    close(F2);
    didit := true;
  end;
  end;

IF paramstr(1) = '/#' then
    begin
    if paramstr(2) = '' then notice2(didit);
    if paramstr(2) <> ''  then
    begin
    Assign(F3, paramstr(2));
    Reset(F3);
    while not Eof(F3) do
    begin
      Read(F3, num);
      Write(num);
      writeln;
      end;
  close(f3);
    didit := true;
  end;
  end;

IF paramstr(1) = '/T' then
    begin
    if paramstr(2) = '' then notice2(didit);
    if paramstr(2) <> '' then
    begin
    Assign(F4, paramstr(2));
    Reset(F4);
    while not Eof(F4) do
    begin
      Readln(F4, strng);
      Writeln(strng);
   end;
    close(F4);
  end;
  didit := true;
  end;

IF paramstr(1) = '/t' then
    begin
    if paramstr(2) = '' then notice2(didit);
    if paramstr(2) <> '' then
    begin
    Assign(F4, paramstr(2));
    Reset(F4);
    while not Eof(F4) do
    begin
      Readln(F4, strng);
      Writeln(strng);
   end;
    close(F4);
  end;
  didit := true;
  end;




IF didit = false then notice3;
IF paramstr(1) = '/?' then notice3;


Writeln;
textcolor(red);
writeln('operation done');
textcolor(7);
writeln('');


end.



