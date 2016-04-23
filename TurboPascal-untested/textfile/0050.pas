{
This unit allows your programs to have professional .INI file entries
that determine its behaviour.  I use this unit in 4 programs so far,
and I plan to keep using it.  It is *very* simple, but nonetheless
rather useful.  An INI file has the following structure:

; Comments are lines that start with a semicolon.  They are ignored.

; Blank lines are also ignored

SECTION = <name>
; SECTION specifies the current INI section.  This allows you to use one
; INI file for several programs, as in WIN.INI. The default SECTION is
; GLOBAL.
<item> = <value>
; <item> is a name (other than section) for an INI entry.  <value> is
; a value for <item>.
; eg: Author=Byron Ellacott
; All spaces before and after the equal sign are ignored.

An INI file can have an unlimited number of sections and items.

SWAG people: Feel free to include this in your next packet
}

unit INI;

interface

type
  TINIOption = record
    ioType: string[20]; { Type of INI option }
    ioSection: string[20]; { Current section }
    ioValue: string[40]; { Value of option }
  end;

{All INI options are returned in a TINIOption record.  It is up to your
 program to then take a course of action or to set a variable accordingly}

function OpenINI(s: string): boolean;
{OpenINI attempts to open the filename S.  If it succeeds, it returns
 true and all further options work on that file.  If it cant find the
 file or cant open it, it returns False}

procedure CloseINI;
{This procedure closes an INI file if one is open.  It checks if one is
 opened before attempting to close it also..}

function GetINIOption(var INIOption: TINIOption): boolean;
{This function gets the next option in the INI file.  Once you have read
 an INI option, you cannot go back through the file.  You will have to
 reopen the file.. If there are no more options, it returns false.  The
 current section will be updated if it is changed (and reflected in
 the global variable CurrentSection)}

function FindSection(section: string): boolean;
{This function seeks through the file until it finds the section passed
 to it.  If it doesnt find it, a return value of False is given}

function UpStr(s: string): string;
{A utility procedure to convert a string to uppercase.  Not particularly
 thrilling..}

var
  CurrentSection: string[20];
{The current section}

implementation

var
  INIOpen: boolean;
  INIFile: text;

function UpStr(s: string): string;
var
  b:byte;
begin
  for b := 1 to length(s) do s[b] := upcase(s[b]);
  UpStr := s;
end;

function OpenINI;
begin
  if INIOpen then close(INIFile);
  assign(INIFile,s);
  {$I-} reset(INIFile); {$I+}
  CurrentSection := 'GLOBAL';
  INIOpen := (ioresult = 0);
  OpenINI := INIOpen;
end;

procedure CloseINI;
begin
  if INIOpen then close(INIFile);
  INIOpen := false;
end;

function ReadLine(var s: string): boolean;
begin
  repeat
    if eof(INIFile) then begin
      ReadLine := false;
      exit;
    end;
    readln(INIFile,s);
  until (length(s) > 0) and (s[1] <> ';');
  if UpStr(copy(s,1,7)) = 'SECTION' then begin
    delete(s,1,7);
    if length(s) > 0 then begin
      while (s[1] = ' ') and (length(s) > 0) do delete(s,1,1);
      if (length(s) > 0) and (s[1] = '=') then begin
        while (s[1] = ' ') and (length(s) > 0) do delete(s,1,1);
        if length(s) > 0 then CurrentSection := s;
      end;
    end;
    ReadLine := ReadLine(s);
  end;
end;

function GetINIOption;
var
  s: string;
  b: byte;
begin
  if not ReadLine(s) then begin
    GetINIOption := false;
    exit;
  end;
  b := pos('=',s);
  if b = 0 then begin
    GetINIOption := GetINIOption(INIOption); { Recurse to find '=' }
    exit;
  end;
  dec(b);
  while s[b] = ' ' do dec(b);
  INIOption.ioType := copy(s,1,b);
  inc(b);
  while s[b] <> '=' do inc(b);
  inc(b);
  while (b < length(s)) and (s[b] = ' ') do inc(b);
  while (length(s) >= b) and (s[length(s)] = ' ') do delete(s,length(s),1);
  INIOption.ioValue := copy(s,b,40);
  INIOption.ioSection := CurrentSection;
  GetINIOption := true;
end;

function FindSection;
var
  s: string;
begin
  reset(INIFile);
  CurrentSection := 'GLOBAL';
  while CurrentSection <> section do begin
    repeat
      if eof(INIFile) then begin
        FindSection := false;
        exit;
      end;
      readln(INIFile,s);
    until (length(s) > 0) and (s[1] <> ';');
    if UpStr(copy(s,1,7)) = 'SECTION' then begin
      delete(s,1,7);
      if length(s) > 0 then begin
        while (s[1] = ' ') and (length(s) > 0) do delete(s,1,1);
        if (length(s) > 0) and (s[1] = '=') then begin
          while (s[1] = ' ') and (length(s) > 0) do delete(s,1,1);
          if length(s) > 0 then CurrentSection := s;
        end;
      end;
    end;
  end;
  FindSection := true;
end;

begin
  CurrentSection := 'GLOBAL';
  INIOpen := false;
end.
