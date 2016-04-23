{
> hi, I've got a question how can I read the textfile in Binary
> mode using Blockread....I am trying to write a multinode program
> and I have to read the textfile in binary mode because SHARE only
> support Binay mode...so If you know how please post me an example....

here is a unit and a conversion prog to convert a text file over
to a binary file that I use for online help in my programs

(I replaced my popupwindows with the crt window)
}

unit display;
interface
uses crt,dos;
Type
   String80 = String[80];
   String65=String[65];
   trecs = record
  fString : String65;
end;
var
helpfile : file of trecs;
trec : trecs;
help_fore, help_back, n,b : Integer;
procedure help(pos:Integer);
function Exist(Filename:String80):boolean;
procedure fwrite(col,row,attrib:byte;str:String80);
{ Write directly to video memory }

implementation
procedure fwrite(col,row,attrib:byte;str:String80);
begin
inline
($1E/$1E/$8A/$86/row/$B3/$50/$F6/$E3/$2B/$DB/$8A/$9E/col/
 $03/$C3/$03/$C0/$8B/$F8/$be/$00/$00/$8A/$BE/attrib/
 $8a/$8e/str/$22/$c9/$74/$3e/$2b/$c0/$8E/$D8/$A0/$49/$04/
 $1F/$2C/$07/$74/$22/$BA/$00/$B8/$8E/$DA/$BA/$DA/$03/$46/
 $8a/$9A/str/$EC/$A8/$01/$75/$FB/$FA/$EC/$A8/$01/$74/$FB/
 $89/$1D/$47/$47/$E2/$Ea/$2A/$C0/$74/$10/$BA/$00/$B0/
 $8E/$DA/$46/$8a/$9A/str/$89/$1D/$47/$47/$E2/$F5/$1F);
end;
function Exist(Filename:String80):boolean;
VAR infile:text;

Begin                        { Find out if the file exists }
   Assign(Infile,Filename);
   {$I-}
   Reset(infile);
   close(infile);
   {$I+}
   Exist := (IOresult = 0);
end;
procedure help(pos:Integer);
{ Read and display help }
const
   filename = 'Demo.hlp'; {this is the name of my help file}

var
   ch : char;
   i  : Integer;
begin
   if not exist(filename) then
   begin
      window(20,10,60,14);
      textcolor(7);
      clrscr;
      writeln('    Help file ''Demo.hlp'' not found.');
      write('        Press any key...');
      Ch := ReadKey;
   end else
   begin
      help_back:=cyan;
      window(5,4,73,19);
      textbackground(3);
      clrscr;
      i := 1;
      assign(helpfile,filename);
      reset(helpfile);
      while not eof(helpfile) do
      begin
         seek(helpfile,pos-1);
         read(helpfile,trec);
            fwrite(7,i+3,help_back*16+help_fore,trec.fString);
         i := succ(i);
         pos := succ(pos);
         if i > 12 then
         begin
            i := 1;
            writeln;
    fwrite(21,17,help_back*16+4,'  Page Up/Page Down or ESC to exit...');
            gotoxy(47,18);
            repeat
               Ch := ReadKey;
            until ch in [#73,#81,#27];
            clrscr;
            if ch = #73 then pos := pos - 30;
            if pos < 1 then pos := 1;
            if ch = #27 then
            begin
               close(helpfile);
               textbackground(b);
               exit
            end;
            clrscr;
         end;
      end;
         fwrite(10,17,help_back*16+4,'Press any key to exit help...');
      gotoxy(35,18);
      Ch := ReadKey;
      close(helpfile);
      textbackground(b);
   end;
end;
end.

{
this will take a regular ascii text file and convert it to a binary
file,Note: the text file cannot have any more than 65 columns,you can
change this simply by replacing 65 with 80 if this is inconvenient,
I use this so that my help file display fits nicely in a window
}
program convert;
Uses
   Crt;
{ Converts 65 char per line help file over to a file of records
 so it can be presented in a window.
}
type
   string65 = string[65];
   recs = record
      line : string65;
   end;

const
   filenameout = 'DEMO.HLP';

var
   diskfilein : text;
   rec : recs;
   diskfileout : file of recs;
   filenamein : string65;
   line : string65;

function Exist(Filename:string65):boolean;
VAR infile:text;
Begin                        { Find out if the file exists }
   Assign(Infile,Filename);
   {$I-}
   Reset(infile);
   {$I+}
   Exist := (IOresult = 0);
   close(infile)
end;

function uppercase(line:String65):String65;
var
   i : integer;
   ch : char;
   temp : string65;

begin
   temp := '';
   for i := 1 to length(line) do
   begin
      ch  := line[i];
      ch := upcase(ch);
      temp := concat(temp,ch);
   end;
   uppercase := temp
end;

begin { Convert }
   clrscr;
   gotoxy(20,10);
   write('Filename to convert ? '); {any text file}
   readln(filenamein);
   if not exist(filenamein) then
   begin
      gotoxy(20,12);
      write('Filename ',filenamein,' not found.');
      halt
   end;
   filenamein := uppercase(filenamein);
      if filenamein = filenameout then
      begin
         gotoxy(20,12); clreol;
         write(#7,'Both filenames can''t have the same name.');
         halt
      end;
   assign(diskfilein,filenamein);
   reset(diskfilein);
   assign(diskfileout,filenameout);
   rewrite(diskfileout);
   while not eof(diskfilein) do
   begin
      readln(diskfilein,line);
      rec.line := line;
      write(diskfileout,rec)
   end;
   close(diskfilein);
   close(diskfileout);
   gotoxy(20,15);
   write(filenameout,' has been created.');
end.

{
this is a little test program to read the binary help file that was
created with Convert.exe included in the previous message.
you can use this in any of your programs that you wish to add online
help to by simply calling HELP(x) ,where x is the line in the file.
ie: help(1) is the first line, help(62) is line 62.

this is probably more than you asked for but I'm sure you can find some
useful stuff here.  :^)
}

program test_help;
uses crt,display;
begin;
textbackground(1);
clrscr;
help(1); {starts displaying the file at line 1
 and allows pg/up/dn to browse}
end.

