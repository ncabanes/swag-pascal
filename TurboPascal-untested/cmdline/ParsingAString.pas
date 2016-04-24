(*
  Category: SWAG Title: COMMAND LINE ROUTINES
  Original name: 0010.PAS
  Description: Parsing a String
  Author: BRIAN PAPE
  Date: 11-02-93  16:39
*)

{
From: BRIAN PAPE
Subj: Reading from strings (PARSE)
---------------------------------------------------------------------------
Can anyone out there tell me how to read a portion of one string
variable into another?

I grabbed this code from one of my batch file utilities.  It isn't real
efficient, as it uses COPY and DELETE, but it doesn't have to be, since
it is only called once a program.  Where I have cfg:cfgrec, just replace
cfgrec with your own kind of record. }

type
  MyRec = record
    r_var : integer;
  end;
...
Anyway, the GET function is what parses the /x:xxxx stuff out of a
regular string.  The PARSE procedure gets the actual command tail
from the PSP and keeps GETting parameters from it until it is empty.
BTW, the atoi() function I used is merely val() turned into a function.
----------------------------------
procedure parse(var cfg:cfgrec);
function get(var s:string):string;
var i,j : byte;slashflag : boolean;
begin
  i := 1;
  while (s[i] = ' ') and (i<=length(s)) do inc(i);
  slashflag := s[i] in ['-','/'];
  j := succ(i);
  while ((slashflag and not (s[j] in ['-','/'])) or
        (not slashflag and not (s[j] = ' '))) and
        (j<=length(s)) do inc(j);
  get := copy(s,i,j-i);
  delete(s,1,j-1);
end;  { get }

var s:^string;t:string;
begin
  s := ptr(prefixseg,$80);  { DTA from PSP }
  cfg.working_msg := '';
  cfg.error_msg := '';
  cfg.drive := 0;
  cfg.pause_on_error := false;
  cfg.how_many_retries := 1;
  while s^<>'' do
    begin
      t := get(s^);
      if t[1] in ['-','/'] then
        begin
          if length(t)>=2 then
            case upcase(t[2]) of
              'C':cfg.how_many_retries :=
                  atoi(strip(copy(t,4,length(t)-3),' '));
              'H','?':begin writehelp; halt(0); end;
              'W':cfg.working_msg := copy(t,4,length(t)-3);
              'E':cfg.error_msg := copy(t,4,length(t)-3);
              'P':cfg.pause_on_error := true;
            end;  { case }
        end  { if }
      else
        cfg.drive := ord(upcase(t[1]))-65;
    end;  { while }
end;  { parse }


