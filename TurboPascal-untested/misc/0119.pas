(*
> Is it possible to display date and time of compilation from
> a program compiled under Borland Pascal?  If yes, how?

if you mean like C programs can do, yes it is possible. it takes an
external utility, a .BAT file, and a "special" line in your program's
CONST section. C programs have a preprocessor that looks for and
replaces tokens with certain information. we just create our own for
this special need/desire...

here's what the "special" line in the program source has to look like...
if it doesn't look just like this, it will NOT work correctly...

const
  progname      : string[6]  = 'PostIt';
  MergeCode     : string[57] = 'Product of Quartz Crystal Software';
> {$I compiled}
  cfgfile       : string[10] = 'POSTIT.CFG';
  tearline      : string[4]  = '--- ';


the key to this is that you have to have the line in a section of
CONST's that are actually used. if none of the other four CONST's above
were used in the program, the time and date of the compile would not be
included in the final .EXE file. whether you display it on the screen or
not is your choice.


first, the .BAT file i use to compile programs with...

@echo off
rem **********************************************************
rem * COMPIT.BAT                                             *
rem *                                                        *
rem * uses a 4DOS specific option %& to pass the rest of the *
rem * command line on to the TPC compiler                    *
rem *                                                        *
rem * TPPP is our Turbo Pascal PreProcessor utility <<smile>>*
rem **********************************************************
if exist compiled.pas del compiled.pas
if '%1' == '' goto error
tppp
tpc /ic:\tp /uc:\tp /tc:\tp /oc:\tp %&
goto end
:error
echo 
echo What file to compile?
echo.
echo  ie: COMPIT thisfile.pas
echo.
:end


now the source to TPPP...
*)

program Turbo_Pascal_Pre_Processor;

{ this program started out as a preprocessor but i've not had a }
{ chance to do more with it than to hard code only a time/date  }
{ string for an include file :(                                 }

uses Dos;

var thefile : text;

function DATE : string;
const
  months : array [1..12] of String[3] =
    ('Jan','Feb','Mar','Apr','May','Jun',
     'Jul','Aug','Sep','Oct','Nov','Dec');
var
  y, m, d, dow : Word;
  daystr  : string;
  yearstr : string;
begin
  GetDate(y,m,d,dow);
  str(d,daystr);
  str(y,yearstr);
  DATE := daystr + ' ' + months[m] + ' ' + yearstr;
end;

function TIME : string;
var
  h, m, s, hund : Word;
  function LeadingZero(w : Word) : String;
  var
    s : String;
  begin
    Str(w:0,s);
    if Length(s) = 1 then
      s := '0' + s;
    LeadingZero := s;
  end;
begin
  GetTime(h,m,s,hund);
  TIME := LeadingZero(h) + ':' + LeadingZero(m);
end;

begin
  assign(thefile,'COMPILED.PAS');
  rewrite(thefile);
  writeln(thefile,
    'compiled : string[32] = ''Compiled on ',DATE,' at ',TIME,''';');
  close(thefile);
end.

{
TPPP was originally going to process source code files that comtained
tokens like C coders can use. something similar to the following...

  compiled : string[32] = 'Compiled on __DATE__ at __TIME__';

i've just not had the time to complete any more of the design and coding
needed... this suits my desires for now...
{
