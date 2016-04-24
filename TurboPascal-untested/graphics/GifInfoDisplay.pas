(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0111.PAS
  Description: Gif info display
  Author: DAVID DANIEL ANDERSON
  Date: 08-24-94  13:40
*)

{
BS> Can anone out there tell me where you get the resoloution out of a Gif file
BS> from? What I am saying is, I would like to make a program to look at a Gif
BS> and grab the resoloution out of it for my dir list files. Any help would be
BS> appreciated.

I've written a freeware program to do just this.  Program name is GRR,
and Pascal source accompanies it.  Here is the source from the latest
(and only) version.  I apologize for the lack of comments, but it is
rather straightforward, I think. }

program getGIFheader;
uses
  dos;
const
  progdata = 'GRR- Free DOS utility: GIF file info displayer.';
  progdat2 =
  'V1.00: August 19, 1993. (c) 1993 by David Daniel Anderson - Reign Ware.';
  usage =
  'Usage:  GRR directory and/or file_spec[.GIF]   Example:  GRR cindyc*';
var
  header : string[6];
  gpixn : byte;
  gpixels, gback, rwidthLSB, rheightLSB, rwidth, rheight : char;
  gifname : string[12];
  giffile : text;
  dirinfo : searchrec;
  gpath : pathstr;
  gdir : dirstr;
  gname : namestr;
  gext : extstr;

procedure showhelp;
begin {-- showhelp --}
  writeln(progdata);
  writeln(progdat2);
  writeln(usage);
  halt;
end {-- showhelp --};

function taffy(astring : string; newlen : byte) : string;
begin {-- taffy --}
  while (length(astring) < newlen) do
    astring := astring + ' ';
  taffy := astring;
end {-- taffy --};

function LeadingZero(w : Word) : string;
var
  s : string;
begin {-- LeadingZero --}
  Str(w : 0, s);
  if (length(s) = 1) then
    s := '0' + s;
  LeadingZero := s;
end {-- LeadingZero --};

procedure writeftime(fdatetime : longint);
var
  Year2 : string;
  DateTimeInf : DateTime;
begin {-- writeftime --}
  UnpackTime(fdatetime, DateTimeInf);
  with DateTimeInf do
  begin
  Year2 := LeadingZero(Year);
  Delete(Year2, 1, 2);
  Write(LeadingZero(Month), '-', LeadingZero(Day), '-', Year2, '  ',
  LeadingZero(Hour), ':', LeadingZero(Min), ':', LeadingZero(Sec));
  end;
end {-- writeftime --};


procedure displaygifscreenstats(screendes : byte);
var
  GCM : Boolean;
begin {-- displaygifscreenstats --}
  GCM := screendes > 128;
  if (screendes > 128) then
    screendes := screendes - 128;
  if (screendes > 64) then
    screendes := screendes - 64;
  if (screendes > 32) then
    screendes := screendes - 32;
  if (screendes > 16) then
    screendes := screendes - 16;
  if (screendes > 8) then
    screendes := screendes - 8;
  case (screendes) of
    0: Write('  2');
    1: Write('  4');
    2: Write('  8');
    3: Write(' 16');
    4: Write(' 32');
    5: Write(' 64');
    6: Write('128');
    7: Write('256');
  end {-- CASE --};
  if (GCM) then
    Write(' ]  GCM/')
  else
    Write(' ]  ---/');
end {-- displaygifscreenstats --};

procedure checkforgiflite(var thefile : text);
var
  ic : Word;
  dummy, glite : char;
  gliteword : string[7];
begin {-- checkforgiflite --}
  for ic := 13 to 784 do
    read(thefile, dummy);
  gliteword := '       ';
  for ic := 1 to 7 do
    begin
    read(thefile, glite);
    gliteword[ic] := glite;
    end;
  if (pos('GIFLITE', gliteword) = 1) then
    Write('GL')
  else
    Write('--');
end {-- checkforgiflite --};

begin {-- getGIFheader --}
  gpath := '';
  gpath := paramstr(1);
  if (gpath = '') then
    gpath := '*.gif';
  if (pos('.', gpath) <> 0) then
    begin
    gpath := copy(gpath, 1, pos('.', gpath));
    gpath := gpath + 'gif'
    end
  else
    gpath := gpath + '*.gif';
  fsplit(fexpand(gpath), gdir, gname, gext);
  findfirst(gpath, archive, dirinfo);
  if (doserror <> 0) then
    showhelp;
  while (doserror = 0) do
    begin
    gifname := dirinfo.name;
    assign(giffile, gdir + gifname);
    reset(giffile);
    read(giffile, header);
    if (pos('GIF', header) <> 1) then
      header := '?_GIF?';
    read(giffile, rwidthLSB, rwidth, rheightLSB, rheight, gpixels, gback);
    gifname := taffy(gifname, 12);
    Write(gifname, '  ', dirinfo.size:7, '  ');
    writeftime(dirinfo.time);
    Write('    ', header, '   [');
    Write((ord(rwidthLSB) + (256 * ord(rwidth))):4, ' ',
         (ord(rheightLSB) + (256 * ord(rheight))):4, '  ');
    gpixn := ord(gpixels);
    displaygifscreenstats(gpixn);
    {         write ( ', ', ord ( gback )); }
    { This is the background color, commented out since it is not used }
    checkforgiflite(giffile);
    writeln;
    close(giffile);
    findnext(dirinfo);
    end;
end {-- getGIFheader --}.

