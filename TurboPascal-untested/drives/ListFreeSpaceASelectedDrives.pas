(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0122.PAS
  Description: List free space a selected drives
  Author: JONATHAN C. WATRIDGE
  Date: 05-30-97  18:17
*)

{
Here's a program i wrote a while ago...i thought everybody at SWAG would
like to grab a copy.  There's still a lot of optimization to be done, so
if anybody wants to play around with it, i'd appreciate it if you'd send
me the results...
}

PROGRAM Space; {...the final frontier...}
USES Crt, Dos;

CONST Title                     = 'SPACE v2.4 (c) 22-MAR-97 reÆper, no rights reserved';

VAR DriveL                      : string[2];
    DriveN                      : shortint;
    Tmp,Tmp2,Tmp3,z             : shortint;
    TmpS                        : string[2];
    size,free                   : INTEGER;
    FreeMemory, Handle, SegAddr, I : word;
    P : pointer;
    d_label                     : string;

TYPE string10=string[10];
     fcbType = Record
                 drive   : Byte;
                 name    : Array[1..8] of Char;
                 ext     : Array[1..3] of Char;
                 fpos    : Word;
                 recsize : Word;
                 fsize   : LongInt;
                 fdate   : Word;
                 ftime   : Word;
                 reserv  : Array[1..8] of Byte;
                 currec  : Byte;
                 relrec  : LongInt;
               end;
     extfcb =  Record
                 flag    : Byte;                  { must be $ff! }
                 reserv  : Array[1..5] of Byte;
                 attrib  : Byte;
                 fcb     : fcbType;
               end;

FUNCTION Str2Int( cNum: STRING ): LONGINT;
VAR
   c: INTEGER;
   i: LONGINT;
BEGIN
     VAL( cNum, i, c );
     Str2Int := i;
END;




function calc_p1(num1,num2:integer):string10;
var
  z:real;
  out1:string[10];
begin
  out1:='  0';
  if num1=0 then exit;
  if num2=0 then exit;
  z:=num1/num2;
  str(z:2:2,out1);
  if out1='1.00' then
    begin
      out1:='100';
      calc_p1:=out1;
      exit;
    end;
  delete(out1,1,2);
  if out1[1]='0' then delete(out1,1,1);
  while length(out1)<2 do insert(' ',out1,1);
  if out1='0' then out1:='100';
  if out1='' then out1:='0';
  calc_p1:=out1;
end;

Function GetVolLabel(drive:string):String; {also from SWAG}
Var sr : SearchRec;
begin
  findfirst(drive+'\*.*',VolumeID,sr);
  if Doserror=0 then GetVolLabel:=sr.name
  else GetVolLabel:='';
end;

{--- this really needs to be optimized --}

PROCEDURE DriveLetter;
BEGIN
  if DriveL = 'A:' then DriveN := (1);     if DriveL = 'B:' then DriveN := (2);
  if DriveL = 'C:' then DriveN := (3);     if DriveL = 'D:' then DriveN := (4);
  if DriveL = 'E:' then DriveN := (5);     if DriveL = 'F:' then DriveN := (6);
  if DriveL = 'G:' then DriveN := (7);     if DriveL = 'H:' then DriveN := (8);
  if DriveL = 'I:' then DriveN := (9);     if DriveL = 'J:' then DriveN := (10);
  if DriveL = 'K:' then DriveN := (11);    if DriveL = 'L:' then DriveN := (12);
  if DriveL = 'M:' then DriveN := (13);    if DriveL = 'N:' then DriveN := (14);
  if DriveL = 'O:' then DriveN := (15);    if DriveL = 'P:' then DriveN := (16);
  if DriveL = 'Q:' then DriveN := (17);    if DriveL = 'R:' then DriveN := (18);
  if DriveL = 'S:' then DriveN := (19);    if DriveL = 'T:' then DriveN := (20);
  if DriveL = 'U:' then DriveN := (21);    if DriveL = 'V:' then DriveN := (22);
  if DriveL = 'W:' then DriveN := (23);    if DriveL = 'X:' then DriveN := (24);
  if DriveL = 'Y:' then DriveN := (25);    if DriveL = 'Z:' then DriveN := (26);

  if DriveL = 'a:' then DriveN := (1);     if DriveL = 'b:' then DriveN := (2);
  if DriveL = 'c:' then DriveN := (3);     if DriveL = 'd:' then DriveN := (4);
  if DriveL = 'e:' then DriveN := (5);     if DriveL = 'f:' then DriveN := (6);
  if DriveL = 'g:' then DriveN := (7);     if DriveL = 'h:' then DriveN := (8);
  if DriveL = 'i:' then DriveN := (9);     if DriveL = 'j:' then DriveN := (10);
  if DriveL = 'k:' then DriveN := (11);    if DriveL = 'l:' then DriveN := (12);
  if DriveL = 'm:' then DriveN := (13);    if DriveL = 'n:' then DriveN := (14);
  if DriveL = 'o:' then DriveN := (15);    if DriveL = 'p:' then DriveN := (16);
  if DriveL = 'q:' then DriveN := (17);    if DriveL = 'r:' then DriveN := (18);
  if DriveL = 's:' then DriveN := (19);    if DriveL = 't:' then DriveN := (20);
  if DriveL = 'u:' then DriveN := (21);    if DriveL = 'v:' then DriveN := (22);
  if DriveL = 'w:' then DriveN := (23);    if DriveL = 'x:' then DriveN := (24);
  if DriveL = 'y:' then DriveN := (25);    if DriveL = 'z:' then DriveN := (26);
END;

PROCEDURE UpCaseString(Str : string);
var
  i : Integer;
begin
  for i := 1 to Length(Str) do
    Str[i] := UpCase(Str[i]);
END;

PROCEDURE Help;
BEGIN
  writeln('USAGE: SPACE [drive1] [drive2] [drive3] etc; etc;');
  writeln('EXMPL: SPACE C: D: F: H: Z:');
  writeln;
  writeln('*** Portions (c) reÆper/VOiD and misc routines are from SWAG.');
  writeln;
  writeln('GREETZ: Silva,Dopey Druid, Cyber-Mage, Mixa, Eternal Dreams,');
  writeln('        Valcan, Indigo, Chris, NACC, everybody,');
  writeln('        involved with SWAG....');
  writeln;
  writeln;
  textattr:=$7;
  writeln(' e-mail me and tell me what you think or for bug reports ');
  writeln(' or just flame!');
  writeln;
  writeln(' Jonathan ');
  writeln(' jonathan@connx.co.za ');
  halt(0);
END;

BEGIN
{---------------------------------------------------------------------------}
  clrscr;
  textattr:=$e; writeln(Title); textattr:=$7;
  if paramcount = 0 then help;
  textattr:=$7;write  ('─=[ DISK SPACE ]=──────────────────────────────────────');
  gotoxy(62,2);write('┬');
  for z := 3 to paramcount + 2 do
  begin
    gotoxy(62,z);write('│');
  end;
    gotoxy(1,z+1);write ('─────────────────────────────────────────────────────');
    if paramcount <=2 then write('────┘');
    if paramcount > 2 then write('────┴──────────────────');
  gotoxy(1,3);
  for tmp := 1 to paramcount do begin
{-- main ------------------------------------------------------------------}
  DriveL := Paramstr(tmp);
  DriveLetter;
  textattr:=$f;
  write(DriveL);
  textattr:=$7;
  D_Label := GetVolLabel(DriveL);
  write(' ',GetVolLabel(DriveL));
  gotoxy(15,whereY);
  write('  size[');textattr:=$f;
  write(disksize(DriveN) div 1000024);textattr:=$7;
  write('mb]');
  gotoxy(30,whereY);
  write('free[');textattr:=$f;
  write(diskfree(DriveN) div 1000024);textattr:=$7;
  write('mb]');
    begin
      size := disksize(DriveN) div 1000024;
      free := diskfree(DriveN) div 1000024;
      textattr:=$f;
      gotoxy(58,whereY);write(calc_p1(free,size),'%');
      textattr:=$7;
      tmp3 := str2int(calc_p1(free,size)) div 10;
      gotoxy(45,whereY);
      write('[');textattr:=$c;      write('·');textattr:=$c;
      write('·');textattr:=$e;      write('·');textattr:=$e;
      write('·');textattr:=$e;      write('·');textattr:=$e;
      write('·');textattr:=$a;      write('·');textattr:=$a;
      write('·');textattr:=$a;      write('·');textattr:=$a;
      write('·');textattr:=$7;      write(']');
      if tmp3 = 10 then textattr:=$a;
      if tmp3 = 9  then textattr:=$a;
      if tmp3 = 8  then textattr:=$a;
      if tmp3 = 7  then textattr:=$a;
      if tmp3 = 6  then textattr:=$e;
      if tmp3 = 5  then textattr:=$e;
      if tmp3 = 4  then textattr:=$e;
      if tmp3 = 3  then textattr:=$e;
      if tmp3 = 2  then textattr:=$c;
      if tmp3 = 1  then textattr:=$c;
      gotoxy(46,wherey);
       for tmp2 := 1 to tmp3 do begin
                                write('■');
                               end;
      writeln;
      textattr:=$7;
  END;
END;
{------------------------- dos mem -----------------------------------------}
  gotoxy(64,3);
  write('BASE:size['); textattr:=$f;
  write('655360');textattr:=$7;
  write(']');
  gotoxy(69,4);
  write('free['); textattr:=$f;
  write(maxavail+29000);textattr:=$7;
  write(']');
  gotoxy(1,paramcount+2);
  writeln;
{--------------------------------------------------------------------------}
END.


Enjoy...
Jonathan


     █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
     █ Jonathan C. Watridge             "Moonlight creeping around the █
     █ ~~~~~~~~~~~~~~~~~~~~              corners of our lawn,  when we █
     █ E-MAîL:  jonathan@connx.co.za     see the early signs that day- █
     █ vΘiCE :  +27 (031) 25 8104        light's fading, we leave just █
     █ FAX   :  +27 (031) 25 8104 (ask)  before it's gone."            █
     █ BBS   :  ...under construction                                  █
     █                                                                 █
     █                                            words by Adam Duritz █
     █ #incluse <disclaimer.h>                   of the Counting Crows █
     █≡=─────────────────────────────────────────────────────────────=≡█
     █ reÆper/VφîD - "CUTTiNG ΣDÇΣ PRODUCTiO∩S"                (z) '97 █
     █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

