(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0023.PAS
  Description: EXE Menu System
  Author: DAVID ADAMSON
  Date: 08-24-94  13:36
*)

{
Here is a good scrolling menu bar program written in TP 5.5. The
code is very clean and well commented.
}

program exemenu;                                      { version 2.2 }



(****************************************** 1991 J.C. Kessels ****

This is freeware. No guarantees whatsoever. You may change it, use it,
copy it, anything you like.


J.C. Kessels
Philips de Goedelaan 7
5615 PN  Eindhoven
Netherlands
********************************************************************)


{$M 3000,0,0}                     { No heap, or we can't use 'exec'. }


uses dos;




const
(* English version: *)
  StrCopyright = 'EXEMENU v2.2, 1991 J.C. Kessels';{ Name of program. }
  StrBusy      = 'Busy....';                       { Program is busy message. }
  StrHelp      = 'Enter=Start  ESC=Stop';         { Bottom-left help message.}
  StrStart     = 'Busy starting program: ';        { Start a program message. }
  { Wrong DOS version message. }
  StrDos = 'Sorry, this program only works with DOS versions 3.xx and above.';
  { Unrecognised error message. }
  StrError     = 'EXEMENU: unrecognised error caused program termination.';
  StrExit      = 'That''s it, folks!';                   { Exit message. }
(* Dutch version: *)
(*
  StrCopyright = 'EXEMENU v2.2, 1991 J.C. Kessels';  { Naam van het programma.}
  StrHelp      = 'Enter=Start  ESC=Stop';       { Bodem-links hulp boodschap.}
  StrBusy      = 'Bezig....';                     { Ik ben bezig boodschap.}
  { Bij het starten van een programma. }
  StrStart     = 'Bezig met starten van: ';
  { Foutboodschap als de DOS versie niet goed is. }
  StrDos = 'Sorry, dit programma werkt slechts met DOS versie 3.xx en hoger.';
  { Onbekende fout boodschap. }
  StrError     = 'EXEMENU: door onbekende fout voortijdig beëindigd.';
  StrExit      = 'Exemenu is geëindigd.';        { Stop EXEMENU boodschap. }
*)

  DirMax = 1000;                    { Number of entries in directory array. }

type
  Str90 = string[90];             { We don't need anything longer than this. }

var
  VidStore : array[0..3999] of char;                 { Video screen storage. }
  Dir : array[1..DirMax] of record  {The directory is loaded into this array.}
    attr : byte;                                     { 1: directory, 2: file.}
    name : NameStr;                              { Name of file/directory. }
    ext  : ExtStr;                                { Extension of file. }
    end;
  DirTop  : word;                        { Last active entry in Dir array. }
  DirHere : word;                       { Current selection in Dir array. }
  DirPath   : pathstr;                { The path of the Loaded directory. }
  OldPath   : PathStr;      { The current directory at startup of EXEMENU. }
  BasicPath : PathStr;                { The path to the basic interpreter. }
  OldCursor : word;                                  { Saved cursor shape. }
  xy     : word;                                  { Cursor on the screen. }
  colour : byte;                                 { Colour for the screen. }
  vidseg : word;                              { Segment of the screen RAM. }
  regs   : registers;                        { Registers to call the BIOS. }
  Inkey  : word;                                   { The last pressed key. }
  keyflags : byte absolute $0040:$0017;             { BIOS keyboard flags. }
  ExitSave : pointer;                         { Address of exit procedure. }
  ExitMsg  : Str90;                      { Message to display when exiting. }
  DTA  : SearchRec;                             { FindFirst-FindNext buffer. }

function Left(s : Str90; width : byte) : Str90;
{Return Width characters from input string. Add trailing spaces if necessary.}
begin
if width > length(s) then Fillchar(s[length(s)+1],width-length(s),32);
s[0] := chr(width);
Left := s;
end;

procedure FixupDir;
{ Fixup the DirPath string. }
var
  drive : char;
  i, j : word;
begin
i := pos(':',DirPath);                   { Strip the drive from the path. }
if i = 0 then
  begin
  if (length(Dirpath) > 0) and (Dirpath[1] = '\')
    then DirPath := copy(OldPath,1,2) + DirPath
    else if OldPath[length(OldPath)] = '\'
      then DirPath := OldPath + DirPath
      else DirPath := OldPath + '\' + DirPath;
  i := pos(':',DirPath);
  end;
drive := DirPath[1];
delete(DirPath,1,i);

while pos('..',DirPath) <> 0 do                    { Remove embedded ".." }
  begin
  i := pos('..',DirPath);
  j := i + 2;
  if i > 1 then dec(i);
  if (i > 1) and (DirPath[i] = '\') then dec(i);
  while (i > 1) and (DirPath[i] <> '\') do dec(i);
  delete(DirPath,i,j-i);
  end;

{ Remove embedded ".\" }
while pos('.\',DirPath) <> 0 do delete(DirPath,pos('.\',DirPath),2);

if pos('\',DirPath) = 0                        { If no subdirectories.... }
  then DirPath := '\'
  else
    begin                          { Else strip filename from the path.... }
    i := pos('.',DirPath);
    if i > 0 then
      begin
      while (i > 0) and (DirPath[i] <> '\') do dec(i);
      if i > 0
        then DirPath := copy(DirPath,1,i)
        else DirPath := '\';
      end;
    if DirPath[length(DirPath)] <> '\'       { maybe add '\' at the end.... }
      then DirPath := DirPath + '\';
    end;

DirPath := drive + ':' + DirPath;    { Add the drive back to the directory. }

{ Translate the Dirpath into all uppercase. }
for i := 1 to length(DirPath) do DirPath[i] := upcase(DirPath[i]);
end;

procedure Show(s : Str90);
{ Display string "s" at "xy", using "colour". This routine uses DMA into the
  video memory. }
begin
Inline(
  $8E/$06/>VIDSEG/       {mov  es,[>vidseg]   ; Fetch video segment in ES.}
  $8B/$3E/>XY/           {mov  di,[>xy]       ; Fetch video offset in DI.}
  $8A/$26/>COLOUR/       {mov  ah,[>colour]   ; Fetch video colour in AH.}
  $1E/                   {push ds             ; Setup DS to stack segment.}
  $8C/$D1/               {mov  cx,ss}
  $8E/$D9/               {mov  ds,cx}
  $8A/$8E/>S/            {mov  cl,[bp+>s]     ; Fetch string size in CX.}
  $30/$ED/               {xor  ch,ch}
  $8D/$B6/>S+1/          {lea  si,[bp+>s+1]   ; Fetch string address in SI.}
  $E3/$04/               {jcxz l2             ; Skip if zero length.}
                         {l1:}
  $AC/                   {lodsb               ; Fetch character from string.}
  $AB/                   {stosw               ; Show character.}
  $E2/$FC/               {loop l1             ; Next character.}
                         {l2:}
  $1F/                   {pop  ds             ; Restore DS.}
  $89/$3E/>XY);          {mov  [>xy],di       ; Store new XY.}
end;

procedure ShowMenu(Message : Str90);
{ Display the screen, with borders, a "Message" in line 2, and the loaded
  directory in the rest of the screen. }
var
  i   : word;                         { Work variable. }
  s   : Str90;                        { Work variable. }
  pagetop : word;                     { Top of the page in the Dir array. }
  row     : word;                     { The display row we are busy with. }
begin
xy := 0;                               { First line. }
colour := $13;
if length(StrCopyright) > 76
  then i := 76
  else i := length(StrCopyright);
s[0] := chr((76 - i) div 2);
Fillchar(s[1],ord(s[0]),'═');
Show('╔'+s+'╡');
colour := $1B;
Show(copy(StrCopyright,1,i));
colour := $13;
s[0] := chr(76 - length(s) - length(StrCopyright));
Fillchar(s[1],ord(s[0]),'═');
Show('╞'+s+'╗║ ');

colour := $1E;                                 { Second line. }
Show(left(Message,76));

colour := $13;                                   { Third line. }
Show(' ║╟──────────────────────────────────────────────────────────────────────────────╢');

{ Display all the directory entries, using the current cursor position
  to calculate the top-left of the page. }
pagetop := DirHere - DirHere mod 105 + 1;
for i := pagetop to pagetop + 20 do
  begin
  colour := $13;
  Show('║ ');
  colour := $1E;
  row := 0;
  while row <= 84 do
    begin
    if i+row <= DirTop
      then if Dir[i+row].attr = 1
        then Show(left(Dir[i+row].name,14))
        else Show(left(Dir[i+row].name,8) + '.' + left(Dir[i+row].ext,5))
      else Show('              ');
    row := row + 21;
    end;
  colour := $13;
  Show('       ║');
  end;

colour := $13;                                      { Last line. }
Show('╚══╡');
colour := $1B;
if length(StrHelp) > 74
  then i := 74
  else i := length(StrHelp);
Show(copy(StrHelp,1,i));
colour := $13;
s[0] := chr(74-i);
Fillchar(s[1],ord(s[0]),'═');
Show('╞'+s+'╝');
end;

procedure ShowBar(here : word; onoff : boolean);
{ Display (onoff = true) or remove (onoff = false) the cursor bar at the screen
  location that shows the "here" entry in the Dir array. Every entry has a
  fixed location on the screen. }
var
  i : word;
begin
i := Here mod 105 - 1;                { Calculate position on screen. }
xy := 484 + (i div 21) * 28 + (i mod 21) * 160;
if onoff                              { Setup the proper colour. }
  then colour := $70
  else colour := $1E;
if Here <= DirTop                     { Display the Dir entry. }
  then if Dir[Here].attr = 1
    then Show(left(Dir[Here].name,12))  { Directories without a dot. }
    else Show(left(Dir[Here].name,8) + '.' + left(Dir[Here].ext,3))
  else Show('            ');              { Empty entries. }
colour := $1E;                            { Reset the colour. }
end;

procedure InitVideo;
{ Initialise the video. If not 80x25 then switch to it. Store the screen.
  Hide the cursor. }
var
  i : byte;
begin
regs.ah := $0F;            { If not text mode 3 or 7, then switch to it. }
intr($10,regs);
i := regs.al and $7F;
regs.ah := $03;            { Save current cursor shape. BH is active page. }
intr($10,regs);
OldCursor := regs.cx;
if (i <> 3) and (i <> 7) then
  begin
  regs.al := 3;
  regs.ah := 0;
  intr($10,regs);
  i := 3;
  end;

if i <> 7                          { Compute video segment. }
  then vidseg := $B800 + (memw[$0040:$004E] shr 4)
  else vidseg := $B000 + (memw[$0040:$004E] shr 4);

move(mem[vidseg:0],VidStore[0],4000);   { Store current screen. }

regs.cx := $2000;                        { Hide cursor. }
regs.ah := 1;
intr($10,regs);

colour := $1E;                             { Reset attribute. }
xy := 0;                                   { Reset cursor. }
end;

procedure ResetVideo;
{ Reset the video back to it's original contents. Show the cursor. }
begin
move(VidStore[0],mem[vidseg:0],4000);       { Restore screen. }

regs.cx := OldCursor;                       { Reset original cursor chape. }
regs.ah := 1;
intr($10,regs);
end;

{$F+}
procedure ExitCode;
{ Reset display upon exit. This also works for error exit's. }
begin
ResetVideo;                           { Reset the original display contents. }
if ExitMsg <> '' then writeln(ExitMsg);    { Show exit message. }
ChDir(OldPath);                            { Restore current path. }
ExitProc := ExitSave;        { Reset previous exit procedure. }
end;
{$F-}

procedure LoadDir;
{ Load the "DirPath" directory into memory. }
var
  i    : word;                                  { Work variable. }
  s    : pathstr;                               { Work variable. }
  name : NameStr;                               { Name of current file. }
  ext  : ExtStr;                                { Extension of current file. }
  attr : byte;                                  { Attribute of current file. }
begin
colour := $1E;                                  { Show "busy" message. }
xy := 164;
Show(left(StrBusy,76));

FixupDir;                               { Cleanup the DirPath string. }
DirTop := 0;                            { Reset pointers into the Dir array.}
DirHere := 1;

FindFirst(DirPath+'*.*',AnyFile,DTA);                 { Find first file. }
while (DosError = 3) and (length(DirPath) > 3) do     { If path not found....}
  begin
  i := length(DirPath);             { then strip last directory from path. }
  if i > 3 then dec(i);
  while (i > 3) and (DirPath[i] <> '\') do dec(i);
  DirPath := copy(DirPath,1,i);
  FindFirst(DirPath+'*.*',AnyFile,DTA);                 { And try again. }
  end;

while DosError = 0 do                                { For all the files. }
  begin
  attr := 0;
  if (DTA.attr and Directory) = Directory
    then
      begin                                      { Setup for directories. }
      name := DTA.name;
      ext := '';
      if DTA.name <> '.' then attr := 1;          { Ignore '.' directory. }
      if DTA.name = '..' then name := '..';
      end
    else
      begin
      for i := 1 to length(DTA.name) do  { Translate filename to lowercase. }
        if DTA.name[i] IN ['A'..'Z'] then
          DTA.name[i] := chr(ord(DTA.name[i])+32);
      i := pos('.',DTA.name);       { Split filename in name and extension. }
      if i > 0
        then
          begin
          name := copy(DTA.name,1,i-1);
          ext  := copy(DTA.name,i+1,length(DTA.name)-i);
          end
        else
          begin
          name := DTA.name;
          ext := '';
          end;
      { Ignore unrecognised extensions. }
      if (ext = 'com') and (DTA.name <> 'command.com') then attr := 2;
      if (ext = 'exe') and (DTA.name <> 'exemenu.exe') then attr := 2;
      if (ext = 'bat') and (DTA.name <> 'autoexec.bat') then attr := 2;
      if (ext = 'bas') and (BasicPath <> '') then attr := 2;
      end;
  { If recognised extension or directory, then load into memory. }
  if attr > 0 then
    begin
    i := 1;
    while (i <= DirTop) and         { Find location where to insert (sort). }
      ((attr > Dir[i].attr) or
      ((attr = Dir[i].attr) and (name > Dir[i].name)) or
      ((attr = Dir[i].attr) and (name = Dir[i].name) and (ext > Dir[i].ext)))
      do inc(i);
    if DirTop < DirMax then inc(DirTop);
    if i < DirTop then              { Move entries up, to create entry. }
      move(Dir[i],Dir[i+1],sizeof(Dir[1]) * (DirTop - i));
    if i <= DirMax then              { Fill the entry. }
      begin
      Dir[i].name := name;
      Dir[i].ext  := ext;
      Dir[i].attr := attr;
      end;
    end;
  FindNext(DTA);                           { Next item. }
  end;

{ Analyse the results. If nothing found (maybe disk error), and if we are in a
  subdirectory, then at least add the parent directory. }
if (DirTop = 0) and (length(DirPath) > 3) then
  begin
  Dir[1].name := '..';
  Dir[1].ext  := '';
  Dir[1].attr := 1;
  DirTop      := 1;
  end;

end;

procedure ExecuteProgram;
{ Execute the program at "DirHere". }
var
  ProgramPath : pathstr;               { Path to the program to execute. }
begin
{ Return from this subroutine if there is no program at the cursor. }
if (DirHere < 1) or (DirHere > DirTop) or (Dir[DirHere].attr <> 2) then exit;

colour := $1E;                           { Show "busy" message. }
xy := 164;
Show(left(StrBusy,76));

{ Setup path to the program. }
ProgramPath := DirPath + Dir[DirHere].name + '.' + Dir[DirHere].ext;

FindFirst(ProgramPath,AnyFile,DTA); { Test if the path to the program exists. }
if DosError <> 0 then exit;                       { Exit if error. }
ResetVideo;                                       { Reset the video screen. }
writeln(StrStart,ProgramPath);                    { Show startup message. }

ChDir(copy(DirPath,1,length(DirPath)-1));        { Change to the directory. }
SwapVectors;                                     { Start program. }
if Dir[DirHere].ext = 'bat'            { .BAT files trough the COMMAND.COM. }
  then Exec(getenv('COMSPEC'),'/C '+ProgramPath)
  else if Dir[DirHere].ext = 'bas'     { .BAS trough the basic interpreter. }
    then Exec(BasicPath,ProgramPath)
    else Exec(ProgramPath,'');                { Others directly. }
SwapVectors;

InitVideo;                                    { Initialise the video. }
ShowMenu(StrBusy);                     { Draw screen with "busy" message. }

{ Reset keyboard flags. }
keyflags := keyflags and $0F;  {Capslock, Numlock, ScrollLock and Insert off.}
fillchar(regs,sizeof(regs),#0);                   { Clear registers. }
regs.ah := 1;                                     { Activate new setting. }
intr($16,regs);

regs.ah := 1;                                    { Clear the keyboard buffer.}
intr($16,regs);
while (regs.flags and fzero) = 0 do
  begin
  regs.ah := 0;
  intr($16,regs);
  regs.ah := 1;
  intr($16,regs);
  end;

Inkey := 13;
end;

var
  i : word;                                            { Workvariable. }
  s : Str90;                                           { Workvariable. }
  OldHere, OldPageTop : word;         { Determine if cursor has moved. }

begin
DirPath := '';                         { No directory loaded right now. }
DirTop := 0;                           { No directory loaded right now. }
ExitMsg := StrError;                   { Reset error message. }
getdir(0,OldPath);                     { Save current directory. }
ExitSave := ExitProc;                  { Setup exit procedure. }
ExitProc := @ExitCode;
InitVideo;                             { Initialise the video. }
ShowMenu(StrBusy);                     { Draw screen with "busy" message. }

if lo(DosVersion) < 3 then             { Test DOS version. }
  begin
  ExitMsg := StrDos;
  halt(1);
  end;

{ Determine what directory to search for programs. Default is the current
  directory. Otherwise the first argument after EXEMENU is used as starting
  path. }
if paramcount = 0
  then DirPath := OldPath
  else DirPath := paramstr(1);

{ Find the basic interpreter somewhere in the path. If not found, then basic
  programs will not be listed. }
BasicPath := Fsearch('GWBASIC.EXE',GetEnv('PATH'));
if BasicPath = '' then BasicPath := Fsearch('GWBASIC.COM',GetEnv('PATH'));
if BasicPath = '' then BasicPath := Fsearch('BASIC.EXE',GetEnv('PATH'));
if BasicPath = '' then BasicPath := Fsearch('BASIC.COM',GetEnv('PATH'));
if BasicPath = '' then BasicPath := Fsearch('BASICA.EXE',GetEnv('PATH'));
if BasicPath = '' then BasicPath := Fsearch('BASICA.COM',GetEnv('PATH'));
if BasicPath <> '' then BasicPath := FExpand(BasicPath);

LoadDir;                               { Load the directory into memory. }
ShowMenu(DirPath);                     { Display the directory. }
ShowBar(DirHere,true);                 { Highlight the current choice. }

{ The main loop, exited only when the user presses ESC. }
repeat
  { Wait for a key to be pressed. Place the scancode in the Inkey variable. }
  regs.ah := 0;
  intr($16,regs);
  Inkey := regs.ax;

  if lo(Inkey) = 13 then               { Process ENTER key. }
    begin
    ShowBar(DirHere,false);            { Remove cursor bar. }
    s := '';                           { No item stored. }
    { If cursor points to a program....}
    if DirHere <= DirTop then if Dir[DirHere].attr = 2
      then
        begin
        { Store the item to execute, so we can move the cursor back to it. }
        s := Dir[DirHere].name + '.' + Dir[DirHere].ext;
        ExecuteProgram;                { Then execute the program....}
        end
      else if Dir[DirHere].name <> '..'   { Else goto the directory....}
        then DirPath := fexpand(DirPath+Dir[DirHere].name) + '\'
        else
          begin                           { Or goto the parent directory. }
          i := length(DirPath) - 1;
          while (i >= 1) and (DirPath[i] <> '\') do dec(i);
          {Store the directory we just left, so we can move the cursor to it.}
          s := copy(DirPath,i+1,length(DirPath)-i-1);
          if i > 0
            then DirPath := copy(DirPath,1,i)
            else DirPath := '\';
          end;
    LoadDir;                              { Reload the directory. }
    { If an item was stored, then find it, and move the cursor to it. }
    if s <> '' then
      begin
      DirHere := 1;
      if pos('.',s) = 0
        then while (DirHere < DirTop) and (Dir[DirHere].name <> s) do
          inc(DirHere)
        else while (DirHere < DirTop) and
          (Dir[DirHere].name + '.' + Dir[DirHere].ext <> s) do inc(DirHere);
      if (DirHere <= DirTop) and (
          ((pos('.',s) = 0) and
           (Dir[DirHere].name <> s)) or
          ((pos('.',s) > 0) and
           (Dir[DirHere].name + '.' + Dir[DirHere].ext <> s)) )
        then DirHere := 1;
      end;
    ShowMenu(DirPath);                    { Show the menu. }
    ShowBar(DirHere,true);                { Show cursor bar. }
    end;

  { Process cursor movement keys. }
  OldHere := DirHere; {Remember current cursor, to determine if it has moved.}
  if (Inkey = $4800) and (DirHere > 1) then dec(DirHere);        { arrow-up.}
  if (Inkey = $5000) and (DirHere < DirTop) then inc(DirHere);   {arrow-down.}
  if (Inkey = $4D00) or (lo(Inkey) = 9) then             {arrow-right or tab.}
    if DirHere + 21 <= DirTop
      then DirHere := DirHere + 21
      else DirHere := DirTop;
  if (Inkey = $4B00) or (Inkey = $0F00) then    { arrow-left or shift-tab. }
    if DirHere > 21
      then DirHere := DirHere - 21
      else DirHere := 1;
  if (Inkey = $5100) and (DirHere < DirTop) then                   { pgdn. }
    if DirTop > 105
      then if DirHere + 105 < DirTop
        then DirHere := DirHere + 105
        else DirHere := DirTop
      else if (DirHere - 1) mod 21 = 20
        then if DirHere + 21 <= DirTop
          then DirHere := DirHere + 21
          else DirHere := DirTop
        else if DirHere - (DirHere - 1) mod 21 + 20 < DirTop
          then DirHere := DirHere - (DirHere - 1) mod 21 + 20
          else DirHere := DirTop;
  if (Inkey = $4900) and (DirHere > 1) then                        { pgup. }
    if DirTop > 105
      then if DirHere > 105
        then DirHere := DirHere - 105
        else DirHere := 1
      else if (DirHere - 1) mod 21 = 0
        then if DirHere > 21
          then DirHere := DirHere - 21
          else DirHere := 1
        else DirHere := DirHere - (DirHere - 1) mod 21;
  if Inkey = $4700 then DirHere := 1;                             { home. }
  if Inkey = $4F00 then DirHere := DirTop;                         { end. }
  if lo(Inkey) > 31 then                      {Process a character inkey. }
    begin
    i := 1;
    while (i <= DirTop) and (Dir[i].name[1] <> chr(lo(Inkey))) do inc(i);
    if i <= DirTop then DirHere := i;
    end;
  if DirHere = 0 then DirHere := 1;           { Correct for empty list. }
  { If the cursor has moved off the screen, then redraw the menu. }
  if OldHere - OldHere mod 105 + 1 <> DirHere - DirHere mod 105 + 1 then
    begin
    ShowBar(OldHere,false);
    ShowMenu(DirPath);
    ShowBar(DirHere,true);
    OldHere := DirHere;
    end;
  if OldHere <> DirHere then    { If the cursor has moved, then redraw it. }
    begin
    ShowBar(OldHere,false);
    ShowBar(DirHere,true);
    end;

until lo(Inkey) = 27;                             { Until ESC key pressed. }

ExitMsg := StrExit;                                   { Exit with message. }
end.

