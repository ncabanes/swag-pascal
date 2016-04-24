(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0041.PAS
  Description: Disk Ready?
  Author: DESCLIN JEAN
  Date: 01-27-94  12:01
*)

{
 some days ago, Bryan Ellis (gt6918b@prism.gatech.edu)
 asked how one could, in TP, check whether a disk in a
 drive is formatted or not. I did not see any answer on
 this posted to the list, so here comes an 'extract' from
 code of mine which might help.

{ The following two procedures were extracted from old file
 copy programs of mine; Therefore they should be 'cleaned-up'
 and fixed up before being included in somebody's code.
 The purpose of the first one is to ensure that:
    a) the target disk (to be written to) is indeed
 present in the drive;
    b) the target disk is a formatted one. If it is
 not, then opportunity is provided for formatting by
 shelling to DOS (rather clumsy, but you get the idea ;-)).

  The purpose of the second procedure is partly redundant
  with that of the first one. It checks whether the disk
  is present in the drive, and it also warns when the disk
  is write protected.
  Calls to ancillary procedures for putting the cursor onto
  the right column and row on the screen, or to clean up
  the display, save and restore the screen, or warning noises
  etc., were removed, which explains the somewhat desultory
  code, which I had no time to rewrite :-( }

  { uses DOS,CRT; }

Procedure CheckDriv(driv : string; var OK:boolean;
       var cc:char   );
{* driv is the string holding the letter of the drive;        *}
{* OK is a global boolean var which must be true in order for  *}
{* the rest of the program to proceed.          *}
{* cc : checks input by the user          *}
{***************************************************************}
var IOR    : integer;
    jk,dr  : char;
    S    : string;
    CmdLine: PathStr;
begin
  OK  := TRUE;
  IOR := 0;
{$I-}
  ChDir(driv);   { make the target drive current }
  { the original current drive letter should be saved in order}
  { to be restored afterwards }
  dr := upcase(driv[1]);
  IOR := IOresult;
  if IOR = 152 then begin
    OK := FALSE;
    writeln('No disk in ',copy(driv,1,2));
    writeln(' (Insert a disk or press ESC)');
    repeat until keypressed;
    cc := readkey
  end
  else
  if IOR = 162 then begin
    OK := FALSE;
    writeln('Unformatted disk in ',copy(driv,1,2));
    writeln('Press ESC to cancel...');
    writeln('...or press ''*'' to format...');
    repeat until keypressed;
    cc := readkey;
    { here, for security sake, only drives A and B were taken
      into account for writing }
    if ((cc = '*') AND ((dr = 'A') OR (dd = 'B'))) then
      begin
 cc := chr(27);
 { now, your Format.com file had better be in the path! }
 S := FSearch('FORMAT.COM', GetEnv('PATH'));
 S := FExpand(S);
 CmdLine := copy(driv,1,2);
 SwapVectors;
 Exec(S,CmdLine);
 SwapVectors;
 If DosError <> 0 then
   write('Dos error #',DosError)
 else
   write('Press any key...');
 repeat until keypressed;
 jk := readkey;
      end
  end
end;
{$I+}

Procedure CheckWrite(var FF: file;
       var OK: boolean;
       var cc: char);
{*   Tests for presence of disk in drive and write protect tab, *}
{*   to allow opening of untyped file for write: this file has *}
{*   of course been assigned before, elsewhere in the program *}
{****************************************************************}
{$I-}
var riteprot : boolean;
    DiskAbsent : boolean;
    error : integer;
begin
  riteprot := TRUE;
  DiskAbsent := TRUE;
  rewrite(FF);
  error := IOResult;
  riteprot := error = 150;
  DiskAbsent := error = 152;
  if riteprot then begin
    writeln('Disk is write protected!');
    writeln('Correct the situation and press any key...');
    repeat until keypressed;
    cc := readkey
  end;
  if DiskAbsent then begin
    writeln('No disk in the drive!');
    writeln('Insert disk into drive, then press any key...');
    repeat until keypressed;
    cc := readkey
  end;
  OK := (Not(riteprot)) AND (Not(DiskAbsent))
end;
{$I+}

