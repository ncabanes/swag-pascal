{
QCD (C) 1995 Scott Tunstall. All rights reserved.
-------------------------------------------------

Using a text file that you have created (called DIRS.TXT) this
routine can quickly CD into any directory without you having
to specify the full path.

(Mind and not overload the table with entries please... will
slow down the old CPU)



For example, in file DIRS.TXT

You could have:

DUNE2
C:\GAMES\DUNE2
...
...
...
...



So whenever this was typed at the command line
CDQ DUNE2

The directory becomes C:\GAMES\DUNE2


You can have as many entries as you like.


}

uses crt, basics;





procedure usage;
begin

     writeln;
     writeln('Usage :');
     writeln;
     writeln('QCD <Entry>');
     writeln;
     writeln('Where <Entry> is a key related to a specific path');
     writeln('contained on the disk (need not be the current disk)');
     writeln;
     writeln('Ask Scott for details if still stuck :)');
     writeln('E-Mail address: INSC3SAT@RIVER.TAY.AC.UK');
     writeln;
     halt;
end;





Function StrCmp(Str1, Str2 : String) : Boolean;
begin
  Str1:=upper(Str1);
  Str2:=upper(Str2);

  if (Length(Str1) = Length(Str2)) and (Pos(Str1, Str2) <> 0) then
    StrCmp := True
  else
    StrCmp := False;
end;






procedure change_dir(entry : string);
var f: text;
    currententry: string[20];
    associateddir: string[80];

begin
     assign(f, '\DIRS.TXT');
     reset(f);
     while not eof(f) do
     begin
          readln(f,currententry);
          readln(f,associateddir);
          if (strcmp(entry, currententry) = True) then
             begin
             close(f);
             {$i-}
             chdir(associateddir);
             if ioresult <> 0 then
                begin
                writeln('Directory ',upper(associateddir),' does not exist !!');
                halt(1);
                end;
             halt(0);
          end;
     end;

     writeln;
     writeln('No match for ',upper(entry),'!. ');
     close(f);
     halt(1);
end;






begin
     writeln;
     writeln;
     writeln('Quick CD (C) 1995 Scott Tunstall. All rights reserved.');

     case paramcount of
     0 : usage;
     1 : change_dir(paramstr(1));
     else
         begin
         writeln('An error occurred: Too many parameters !!');
         usage;
         end;
     end;

end.