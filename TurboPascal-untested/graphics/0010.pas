{
RANDY PARKER

> Does anyone out there knwo how you can compile a Program using one of
> Borland's BGI units for grpahics and not have to distribute the BGI
> file(s) with the EXE?

   First, convert the BGI and CHR files to .OBJ files (object) by using
BINOBJ.EXE.  You may just want to clip out the following and name it as a batch
file.

   BINOBJ.EXE goth.chr goth gothicfontproc
   BINOBJ.EXE litt.chr litt smallfontproc
   BINOBJ.EXE sans.chr sans sansseriffontproc
   BINOBJ.EXE trip.chr trip triplexfontproc
   BINOBJ.EXE cga.bgi cga cgadriverproc
   BINOBJ.EXE egavga.bgi egavga egavgadriverproc
   BINOBJ.EXE herc.bgi herc hercdriverproc
   BINOBJ.EXE pc3270.bgi pc3270 pc3270driverproc
   BINOBJ.EXE at.bgi att attdriverproc

   You should now have the following files:

     ATT.OBJ, CGA.OBJ, EGAVGA.OBJ GOTH.OBJ HERC.OBJ LITT.OBJ PC3270.OBJ,
     SANS.OBJ, TRIP.OBJ.
}

unit GrDriver;

interface

uses Graph;

implementation

procedure ATTDriverProc;    External; {$L ATT.OBJ}
procedure CGADriverProc;    External; {$L CGA.OBJ}
procedure EGAVGADriverProc; External; {$L EGAVGA.OBJ}
procedure HercDriverProc;   External; {$L HERC.OBJ}
procedure PC3270DriverProc; External; {$L PC3270.OBJ}

procedure ReportError(s : string);
begin
  writeln;
  writeln(s, ': ', GraphErrorMsg(GraphResult));
  Halt(1);
end;

begin
  if RegisterBGIdriver(@ATTDriverProc) < 0 then
    ReportError('AT&T');
  if RegisterBGIdriver(@CGADriverProc) < 0 then
    ReportError('CGA');
  if RegisterBGIdriver(@EGAVGADriverProc) < 0 then
    ReportError('EGA-VGA');
  if RegisterBGIdriver(@HercDriverProc) < 0 then
    ReportError('Hercules');
  if RegisterBGIdriver(@PC3270DriverProc) < 0 then
    ReportError('PC-3270');
end.


unit GrFont;

interface

uses
  Graph;

implementation

procedure GothicFontProc;    External; {$L GOTH.OBJ}
procedure SansSerifFontProc; External; {$L SANS.OBJ}
procedure SmallFontProc;     External; {$L LITT.OBJ}
procedure TriplexFontProc;   External; {$L TRIP.OBJ}

procedure ReportError(s : string);
begin
  writeln;
  writeln(s, ' font: ', GraphErrorMsg(GraphResult));
  halt(1)
end;

begin
  if RegisterBGIfont(@GothicFontProc) < 0 then
    ReportError('Gothic');
  if RegisterBGIfont(@SansSerifFontProc) < 0 then
    ReportError('SansSerif');
  if RegisterBGIfont(@SmallFontProc) < 0 then
    ReportError('Small');
  if RegisterBGIfont(@TriplexFontProc) < 0 then
    ReportError('Triplex');
end.

{
By using the 2 units above, you should be able to include any video driver
of font (that were listed) by simply inserting

Uses
  GrFont, GrDriver, Graph;

into your graphic files.

I got this out of a book name Mastering Turbo Pascal 6, by Tom Swan. It's an
excellent book that covers from Turbo 4.0 to 6.0, basics to advanced subjects.
Hope it works for you.
}
